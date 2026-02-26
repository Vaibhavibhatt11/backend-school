const rateLimit = require("express-rate-limit");
const env = require("../config/env");

const loginRateLimiter = rateLimit({
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
});

module.exports = { loginRateLimiter };
