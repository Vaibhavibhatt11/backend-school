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
  try {
    await withTimeout(
      prisma.$queryRaw`SELECT 1`,
      env.HEALTHCHECK_DB_TIMEOUT_MS,
      "Database readiness timeout"
    );
    return { status: "up" };
  } catch (error) {
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
