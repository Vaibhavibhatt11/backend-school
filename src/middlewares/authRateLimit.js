const rateLimit = require("express-rate-limit");
const { RedisStore } = require("rate-limit-redis");
const env = require("../config/env");
const { getRedis } = require("../config/redis");

const baseLimiterOptions = {
  windowMs: env.LOGIN_RATE_LIMIT_WINDOW_MS,
  max: env.LOGIN_RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true,
  requestWasSuccessful: (req, res) => res.statusCode < 400,
  handler: (req, res) => {
    return res.status(429).json({
      success: false,
      error: {
        code: "TOO_MANY_REQUESTS",
        message: "Too many failed login attempts. Try again later.",
      },
    });
  },
};

function buildRedisLimiter() {
  if (env.LOGIN_RATE_LIMIT_USE_REDIS !== "true") return null;

  const redis = getRedis();
  if (!redis) return null;

  try {
    const store = new RedisStore({
      prefix: "rl:login:",
      sendCommand: (...args) => redis.call(...args),
    });

    return rateLimit({
      ...baseLimiterOptions,
      store,
      passOnStoreError: true,
    });
  } catch (error) {
    console.error("[rate-limit] redis store init failed:", error.message);
    return null;
  }
}

const loginRateLimiter = buildRedisLimiter() || rateLimit(baseLimiterOptions);

module.exports = { loginRateLimiter };
