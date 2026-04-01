const { PrismaClient } = require("@prisma/client");

const env = require("../config/env");

const TRANSIENT_PRISMA_CODES = new Set(["P1001", "P1017", "P2024"]);
const PRISMA_READY_CACHE_MS = 5_000;
const PRISMA_STATE_KEY = "__schoolErpPrismaState";

function createPrismaClient() {
  return new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
  });
}

function withTimeout(promise, timeoutMs, errorMessage) {
  return Promise.race([
    promise,
    new Promise((_, reject) => {
      setTimeout(() => reject(new Error(errorMessage)), timeoutMs).unref();
    }),
  ]);
}

function isTransientPrismaError(error) {
  if (!error || typeof error !== "object") return false;
  if (TRANSIENT_PRISMA_CODES.has(error.code)) return true;

  const message = String(error.message || "").toLowerCase();
  return (
    message.includes("server has closed the connection") ||
    message.includes("connection terminated unexpectedly") ||
    message.includes("connection is closed") ||
    message.includes("socket has been closed") ||
    message.includes("can't reach database server")
  );
}

function createState() {
  return {
    client: createPrismaClient(),
    ensurePromise: null,
    lastReadyAt: 0,
  };
}

const state = globalThis[PRISMA_STATE_KEY] ?? createState();
if (process.env.NODE_ENV !== "production") {
  globalThis[PRISMA_STATE_KEY] = state;
}

function getPrismaClient() {
  return state.client;
}

async function pingClient(client, timeoutMs = env.HEALTHCHECK_DB_TIMEOUT_MS) {
  await withTimeout(
    client.$queryRawUnsafe("SELECT 1"),
    timeoutMs,
    "Database readiness timeout"
  );
}

async function recreatePrismaClient(timeoutMs = env.HEALTHCHECK_DB_TIMEOUT_MS) {
  const previousClient = state.client;
  const nextClient = createPrismaClient();

  state.client = nextClient;

  try {
    await pingClient(nextClient, timeoutMs);
    state.lastReadyAt = Date.now();
  } catch (error) {
    state.client = previousClient;
    await nextClient.$disconnect().catch(() => {});
    throw error;
  }

  await previousClient.$disconnect().catch(() => {});
  return nextClient;
}

async function ensureReady(options = {}) {
  const force = options.force === true;
  const timeoutMs = options.timeoutMs || env.HEALTHCHECK_DB_TIMEOUT_MS;
  const now = Date.now();

  if (!force && state.lastReadyAt && now - state.lastReadyAt < PRISMA_READY_CACHE_MS) {
    return state.client;
  }

  if (state.ensurePromise) {
    return state.ensurePromise;
  }

  state.ensurePromise = (async () => {
    try {
      await pingClient(state.client, timeoutMs);
      state.lastReadyAt = Date.now();
      return state.client;
    } catch (error) {
      if (!isTransientPrismaError(error)) {
        throw error;
      }

      console.warn("[prisma] transient database disconnect detected, recreating client");
      const nextClient = await recreatePrismaClient(timeoutMs);
      console.warn("[prisma] database client recovered");
      return nextClient;
    }
  })().finally(() => {
    state.ensurePromise = null;
  });

  return state.ensurePromise;
}

async function resetClient(options = {}) {
  const timeoutMs = options.timeoutMs || env.HEALTHCHECK_DB_TIMEOUT_MS;
  return recreatePrismaClient(timeoutMs);
}

const helperMethods = {
  createPrismaClient,
  ensureReady,
  getPrismaClient,
  isTransientPrismaError,
  resetClient,
};

const prismaProxy = new Proxy(helperMethods, {
  get(target, prop, receiver) {
    if (Reflect.has(target, prop)) {
      return Reflect.get(target, prop, receiver);
    }

    const client = getPrismaClient();
    const value = client[prop];
    return typeof value === "function" ? value.bind(client) : value;
  },
  has(target, prop) {
    return Reflect.has(target, prop) || prop in getPrismaClient();
  },
  set(target, prop, value, receiver) {
    if (Reflect.has(target, prop)) {
      return Reflect.set(target, prop, value, receiver);
    }

    getPrismaClient()[prop] = value;
    return true;
  },
});

module.exports = prismaProxy;
