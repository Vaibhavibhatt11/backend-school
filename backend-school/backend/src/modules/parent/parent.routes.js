const router = require("express").Router();
const { requireAuth } = require("../student/student.security");

const {
  listChildren,
  getHome,
  getAnnouncements,
  getNotifications,
  markNotificationsRead,
  getAttendance,
  createLeaveRequest,
  getFees,
  getFinanceHub,
  getInvoiceDetail,
  getTimetable,
  getExamTimetable,
  getEventTimetable,
  createMeetingRequest,
  getMeetings,
  getMessages,
  createMessage,
  getProgressReports,
  getLiveClasses,
  getProfileHub,
  updateProfileHub,
  getLibrary,
  getDocuments,
  getEventsHub,
  registerForEvent,
  cancelEventRegistration,
  getAchievements,
  getSettings,
  updateSettings,
  payInvoiceBalance,
  quickPayAllInvoices,
} = require("./parent.handlers");

// All parent routes require valid JWT (401 if missing)
router.use(requireAuth);

router.get("/children", listChildren);
router.get("/home", getHome);
router.get("/announcements", getAnnouncements);
router.get("/notifications", getNotifications);
router.post("/notifications/mark-all-read", markNotificationsRead);
router.get("/attendance", getAttendance);
router.post("/leave-requests", createLeaveRequest);
router.get("/fees", getFees);
router.get("/finance-hub", getFinanceHub);
router.get("/invoices/:invoiceId", getInvoiceDetail);
router.get("/timetable", getTimetable);
router.get("/exam-timetable", getExamTimetable);
router.get("/event-timetable", getEventTimetable);
router.post("/meetings/request", createMeetingRequest);
router.get("/meetings", getMeetings);
router.get("/messages", getMessages);
router.post("/messages", createMessage);
router.get("/progress-reports", getProgressReports);
router.get("/live-classes", getLiveClasses);
router.get("/profile-hub", getProfileHub);
router.put("/profile-hub", updateProfileHub);
router.get("/library", getLibrary);
router.get("/documents", getDocuments);
router.get("/events", getEventsHub);
router.post("/events/:eventId/register", registerForEvent);
router.post("/events/:eventId/cancel", cancelEventRegistration);
router.get("/achievements", getAchievements);

router.get("/settings", getSettings);
router.put("/settings", updateSettings);

// Parent payments
router.post("/invoices/:invoiceId/pay-balance", payInvoiceBalance);
router.post("/fees/quick-pay-all", quickPayAllInvoices);

module.exports = router;

