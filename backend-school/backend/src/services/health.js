const env = require("../config/env");
const prisma = require("../lib/prisma");
const { pingRedis } = require("../config/redis");

async function checkDatabase() {
  try {
    await prisma.ensureReady({ force: true });
    return { status: "up" };
  } catch (error) {
    return { status: "down", error: error.message };
  }
}

function isRedisRequired() {
  return env.LOGIN_RATE_LIMIT_USE_REDIS === "true" || env.API_RATE_LIMIT_USE_REDIS === "true";
}

async function getReadinessStatus() {
  const [database, redis] = await Promise.all([checkDatabase(), pingRedis()]);
  const redisRequired = isRedisRequired();
  const redisHealthy = redis.status === "up" || redis.status === "disabled";
  const ready = database.status === "up" && (redisHealthy || !redisRequired);

  return {
    ready,
    status: ready
      ? redis.status === "down" && !redisRequired
        ? "degraded"
        : "ready"
      : "not_ready",
    checks: {
      database,
      redis: {
        ...redis,
        required: redisRequired,
      },
    },
  };
}

module.exports = { getReadinessStatus };
