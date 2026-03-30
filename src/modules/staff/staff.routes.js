const router = require("express").Router();

const {
  getStaffDashboard,
  getStaffProfile,
  getStaffReports,
  getStaffCommunication,
} = require("./staff.handlers");

router.get("/dashboard", getStaffDashboard);
router.get("/profile", getStaffProfile);
router.get("/reports", getStaffReports);
router.get("/communication", getStaffCommunication);

module.exports = router;
