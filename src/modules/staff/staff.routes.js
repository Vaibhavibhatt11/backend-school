const router = require("express").Router();

const {
  getStaffDashboard,
  getStaffProfile,
  getStaffReports,
  getStaffCommunication,
  sendStaffMessage,
  saveMeetingNote,
} = require("./staff.handlers");

router.get("/dashboard", getStaffDashboard);
router.get("/profile", getStaffProfile);
router.get("/reports", getStaffReports);
router.get("/communication", getStaffCommunication);
router.post("/communication/messages", sendStaffMessage);
router.post("/communication/meeting-notes", saveMeetingNote);

module.exports = router;
