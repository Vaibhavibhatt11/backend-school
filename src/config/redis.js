const Redis = require("ioredis");
const env = require("./env");

let redis = null;
let connectPromise = null;

async function connectRedis(client) {
  if (client.status === "ready" || client.status === "connect") return client;
  if (!connectPromise) {
    connectPromise = client.connect().finally(() => {
      connectPromise = null;
    });
  }
  await connectPromise;
  return client;
}

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

module.exports = { getRedis, pingRedis };
