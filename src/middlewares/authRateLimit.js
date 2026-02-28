const rateLimit = require("express-rate-limit");
const { RedisStore } = require("rate-limit-redis");
const env = require("../config/env");
const { getRedis } = require("../config/redis");

function buildRateLimitStore() {
  const redis = getRedis();
  if (!redis) return undefined;

  return new RedisStore({
    prefix: "rl:login:",
    sendCommand: (...args) => redis.call(...args),
  });
}

const store = buildRateLimitStore();

const loginRateLimiter = rateLimit({
  windowMs: env.LOGIN_RATE_LIMIT_WINDOW_MS,
  max: env.LOGIN_RATE_LIMIT_MAX,
  store,
  passOnStoreError: true,
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
});

module.exports = { loginRateLimiter };
