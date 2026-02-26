const Redis = require("ioredis");
const env = require("./env");

let redis = null;

function getRedis() {
  if (!env.REDIS_URL) return null;
  if (redis) return redis;

  redis = new Redis(env.REDIS_URL, {
    maxRetriesPerRequest: 2,
    lazyConnect: true,
  });

  redis.on("error", (error) => {
    console.error("Redis error:", error.message);
  });

  return redis;
}

module.exports = { getRedis };

