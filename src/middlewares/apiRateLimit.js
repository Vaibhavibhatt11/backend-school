/**
 * Global API rate limiter for scalability (e.g. 1 lakh users).
 * Uses Redis store when REDIS_URL + API_RATE_LIMIT_USE_REDIS=true for multi-instance consistency.
 */
const rateLimit = require("express-rate-limit");
const { RedisStore } = require("rate-limit-redis");
const env = require("../config/env");
const { getRedis } = require("../config/redis");

function shouldSkip(req) {
  const path = (req.path || "").replace(/\/$/, "");
  return path === "/health" || path === "/ready" || path === "/auth/login";
}

const baseOptions = {
  windowMs: env.API_RATE_LIMIT_WINDOW_MS,
  max: env.API_RATE_LIMIT_MAX_PER_IP,
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => shouldSkip(req),
  handler: (req, res) => {
    return res.status(429).json({
      success: false,
      error: {
        code: "TOO_MANY_REQUESTS",
        message: "Too many requests. Please try again later.",
      },
    });
  },
};

function buildApiRateLimiter() {
  if (env.API_RATE_LIMIT_USE_REDIS === "true") {
    const redis = getRedis();
    if (redis && (redis.status === "ready" || redis.status === "connect")) {
      try {
        const store = new RedisStore({
          prefix: "rl:api:",
          sendCommand: (...args) => redis.call(...args),
        });
        return rateLimit({
          ...baseOptions,
          store,
          passOnStoreError: true,
        });
      } catch (err) {
        console.warn("[apiRateLimit] Redis store init failed, using memory:", err.message);
      }
    } else if (redis) {
      console.warn("[apiRateLimit] Redis not ready, using memory store");
    }
  }
  return rateLimit(baseOptions);
}

const apiRateLimiter = buildApiRateLimiter();

module.exports = { apiRateLimiter };
