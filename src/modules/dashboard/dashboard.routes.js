const router = require("express").Router();
const {
  schoolAdminDashboard,
  hrDashboard,
  accountantDashboard,
} = require("./dashboard.handlers");

router.get("/school-admin", schoolAdminDashboard);
router.get("/hr", hrDashboard);
router.get("/accountant", accountantDashboard);

module.exports = router;
