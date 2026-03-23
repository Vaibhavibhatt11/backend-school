const Redis = require("ioredis");
const env = require("./env");

let redis = null;
let connectPromise = null;
let redisDisabled = false;

async function connectRedis(client) {
  if (redisDisabled) {
    throw new Error("Redis disabled after connection failure");
  }
  if (client.status === "ready" || client.status === "connect") return client;
  if (!connectPromise) {
    connectPromise = client
      .connect()
      .catch((error) => {
        redisDisabled = true;
        try {
          client.disconnect(false);
        } catch {
          // ignore cleanup error
        }
        throw error;
      })
      .finally(() => {
        connectPromise = null;
      });
  }
  await connectPromise;
  return client;
}

function getRedis() {
  if (redisDisabled) return null;
  if (!env.REDIS_URL) return null;
  if (redis) return redis;

  redis = new Redis(env.REDIS_URL, {
    maxRetriesPerRequest: null,
    lazyConnect: true,
    enableOfflineQueue: false,
    retryStrategy: (times) => Math.min(times * 100, 5000),
    connectTimeout: 5000,
    commandTimeout: 5000,
  });

  redis.on("error", (error) => {
    const message = error?.message || error?.code || String(error);
    console.error("Redis error:", message);
  });

  return redis;
}

async function pingRedis() {
  const client = getRedis();
  if (!client) {
    return { enabled: false, status: "disabled" };
  }

  try {
    await connectRedis(client);
    await client.ping();
    return { enabled: true, status: "up" };
  } catch (error) {
    return { enabled: true, status: "down", error: error.message };
  }
}

module.exports = { getRedis, connectRedis, pingRedis };
