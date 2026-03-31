const prisma = require("../lib/prisma");
const env = require("../config/env");
const { pingRedis } = require("../config/redis");

function withTimeout(promise, timeoutMs, errorMessage) {
  return Promise.race([
    promise,
    new Promise((_, reject) => {
      setTimeout(() => reject(new Error(errorMessage)), timeoutMs).unref();
    }),
  ]);
}

async function checkDatabase() {
  const isRetryableDisconnect = (error) => {
    const message = String(error?.message || "").toLowerCase();
    return (
      error?.code === "P1001" ||
      error?.code === "P1017" ||
      error?.code === "P2024" ||
      message.includes("server has closed the connection") ||
      message.includes("connection terminated unexpectedly") ||
      message.includes("connection is closed")
    );
  };

  const pingDb = () =>
    withTimeout(
      prisma.$queryRaw`SELECT 1`,
      env.HEALTHCHECK_DB_TIMEOUT_MS,
      "Database readiness timeout"
    );

  try {
    await pingDb();
    return { status: "up" };
  } catch (error) {
    if (isRetryableDisconnect(error)) {
      try {
        // Recover from stale pooled connection (common after DB sleep/wake).
        await prisma.$disconnect();
        await new Promise((resolve) => setTimeout(resolve, 250));
        await pingDb();
        return { status: "up" };
      } catch (retryError) {
        return { status: "down", error: retryError.message };
      }
    }
    return { status: "down", error: error.message };
  }
}

async function getReadinessStatus() {
  const [database, redis] = await Promise.all([checkDatabase(), pingRedis()]);
  const isReady = database.status === "up" && redis.status !== "down";

  return {
    ready: isReady,
    checks: {
      database,
      redis,
    },
  };
}

module.exports = { getReadinessStatus };
