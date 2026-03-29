const router = require("express").Router();
const auth = require("../../middlewares/auth");
const { loginRateLimiter } = require("../../middlewares/authRateLimit");
const {
  login,
  refresh,
  logout,
  me,
  forgotPassword,
  verifyOtp,
  resetPassword,
  changePassword,
} = require("./auth.handlers");

router.post("/login", loginRateLimiter, login);
router.post("/refresh", refresh);
router.post("/logout", logout);
router.get("/me", auth, me);
router.post("/forgot-password", forgotPassword);
router.post("/verify-otp", verifyOtp);
router.post("/reset-password", resetPassword);
router.post("/change-password", auth, changePassword);

module.exports = router;
