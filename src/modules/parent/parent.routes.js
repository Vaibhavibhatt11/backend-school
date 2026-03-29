const router = require("express").Router();
const { requireAuth } = require("../student/student.security");

const {
  listChildren,
  getHome,
  getAnnouncements,
  getNotifications,
  getAttendance,
  getFees,
  getInvoiceDetail,
  getTimetable,
  getProgressReports,
  getLiveClasses,
  getProfileHub,
  getLibrary,
  getDocuments,
  aiAsk,
  aiCareer,
  getSettings,
  updateSettings,
} = require("./parent.handlers");

// All parent routes require valid JWT (401 if missing)
router.use(requireAuth);

router.get("/children", listChildren);
router.get("/home", getHome);
router.get("/announcements", getAnnouncements);
router.get("/notifications", getNotifications);
router.get("/attendance", getAttendance);
router.get("/fees", getFees);
router.get("/invoices/:invoiceId", getInvoiceDetail);
router.get("/timetable", getTimetable);
router.get("/progress-reports", getProgressReports);
router.get("/live-classes", getLiveClasses);
router.get("/profile-hub", getProfileHub);
router.get("/library", getLibrary);
router.get("/documents", getDocuments);
router.post("/ai/ask", aiAsk);
router.get("/ai/career", aiCareer);

router.get("/settings", getSettings);
router.put("/settings", updateSettings);

module.exports = router;

