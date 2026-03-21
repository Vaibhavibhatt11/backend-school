const router = require("express").Router();
const { requireAuth } = require("./student.security");
const {
  dashboard,
  getProfile,
  updateProfile,
  getTimetable,
  getAttendance,
  getHomework,
  getHomeworkById,
  submitHomework,
  getStudyMaterials,
  getExams,
  getExamResultById,
  getExamTimetable,
  getFees,
  getFeesReceipts,
  getPaymentReceipt,
  getAnnouncements,
  getEvents,
  registerForEvent,
  getTransport,
  getLibrary,
  getLibraryBooks,
  getAchievements,
  getNotifications,
  getCirculars,
  getHealth,
  getSettings,
  updateSettings,
  getLeaveRequests,
  createLeaveRequest,
  getSubjectTeachers,
  createMeetingRequest,
  aiAsk,
  aiCareer,
  getReportCards,
  getDocuments,
} = require("./student.handlers");

// All student routes require valid JWT (401 if missing)
router.use(requireAuth);

router.get("/dashboard", dashboard);
router.get("/profile", getProfile);
router.put("/profile", updateProfile);
router.get("/timetable", getTimetable);
router.get("/attendance", getAttendance);
router.get("/homework", getHomework);
router.get("/homework/:id", getHomeworkById);
router.post("/homework/:id/submit", submitHomework);
router.get("/study-materials", getStudyMaterials);
router.get("/exams", getExams);
router.get("/exams/:id/result", getExamResultById);
router.get("/exam-timetable", getExamTimetable);
router.get("/fees", getFees);
router.get("/fees/receipts", getFeesReceipts);
router.get("/payments/:id/receipt", getPaymentReceipt);
router.get("/announcements", getAnnouncements);
router.get("/events", getEvents);
router.post("/events/:id/register", registerForEvent);
router.get("/transport", getTransport);
router.get("/library", getLibrary);
router.get("/library/books", getLibraryBooks);
router.get("/achievements", getAchievements);
router.get("/notifications", getNotifications);
router.get("/circulars", getCirculars);
router.get("/health", getHealth);
router.get("/settings", getSettings);
router.put("/settings", updateSettings);
router.get("/leave-requests", getLeaveRequests);
router.post("/leave-requests", createLeaveRequest);
router.get("/subject-teachers", getSubjectTeachers);
router.post("/meetings/request", createMeetingRequest);
router.post("/ai/ask", aiAsk);
router.get("/ai/career", aiCareer);
router.get("/report-cards", getReportCards);
router.get("/documents", getDocuments);

module.exports = router;
