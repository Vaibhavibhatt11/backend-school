const router = require("express").Router();

const {
  getStaffDashboard,
  getStaffProfile,
  getStaffReports,
  getStaffCommunication,
  sendStaffMessage,
  saveMeetingNote,
  getStaffSettings,
  updateStaffSettings,
  postStaffAiAssist,
} = require("./staff.handlers");

router.get("/dashboard", getStaffDashboard);
router.get("/profile", getStaffProfile);
router.get("/reports", getStaffReports);
router.get("/communication", getStaffCommunication);
router.post("/communication/messages", sendStaffMessage);
router.post("/communication/meeting-notes", saveMeetingNote);
router.post("/ai/assist", postStaffAiAssist);
router.get("/settings", getStaffSettings);
router.put("/settings", updateStaffSettings);

module.exports = router;
