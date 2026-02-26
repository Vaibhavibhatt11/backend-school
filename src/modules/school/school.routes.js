const router = require("express").Router();
const {
  listParents,
  inviteParent,
  resendParentOtp,
  listStaff,
  createStaff,
  updateStaff,
  deleteStaff,
  listRoles,
  createRole,
  updateRole,
  deleteRole,
} = require("./school.people.handlers");
const {
  listClasses,
  createClass,
  updateClass,
  deleteClass,
  listSubjects,
  createSubject,
  updateSubject,
  deleteSubject,
  attendanceOverview,
  markAttendance,
  bulkMarkAttendance,
} = require("./school.academic.core.handlers");
const {
  getTimetable,
  createTimetableSlot,
  updateTimetableSlot,
  deleteTimetableSlot,
  publishTimetable,
  listLiveClassSessions,
  createLiveClassSession,
  updateLiveClassSession,
  endLiveClassSession,
} = require("./school.schedule.handlers");
const {
  getFeesSummary,
  listFeeStructures,
  createFeeStructure,
  updateFeeStructure,
  deleteFeeStructure,
  listInvoices,
  createInvoice,
  getInvoiceById,
  updateInvoiceStatus,
  listPayments,
  createPayment,
  getPaymentReceipt,
  listReportJobs,
  generateReport,
} = require("./school.finance.handlers");
const {
  listAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
  sendAnnouncement,
  listAuditLogs,
  getSettings,
  updateSettings,
  listFaceCheckins,
  approveFaceCheckin,
  rejectFaceCheckin,
  listAiFaqs,
  createAiFaq,
  updateAiFaq,
  deleteAiFaq,
} = require("./school.misc.handlers");
const {
  listExams,
  createExam,
  updateExam,
  deleteExam,
  saveExamMarks,
  publishExam,
} = require("./school.exams.handlers");

router.get("/parents", listParents);
router.post("/parents/invite", inviteParent);
router.post("/parents/:id/resend-otp", resendParentOtp);

router.get("/staff", listStaff);
router.post("/staff", createStaff);
router.put("/staff/:id", updateStaff);
router.delete("/staff/:id", deleteStaff);

router.get("/classes", listClasses);
router.post("/classes", createClass);
router.put("/classes/:id", updateClass);
router.delete("/classes/:id", deleteClass);

router.get("/subjects", listSubjects);
router.post("/subjects", createSubject);
router.put("/subjects/:id", updateSubject);
router.delete("/subjects/:id", deleteSubject);

router.get("/attendance/overview", attendanceOverview);
router.post("/attendance/mark", markAttendance);
router.post("/attendance/bulk-mark", bulkMarkAttendance);

router.get("/timetable", getTimetable);
router.post("/timetable/slots", createTimetableSlot);
router.put("/timetable/slots/:id", updateTimetableSlot);
router.delete("/timetable/slots/:id", deleteTimetableSlot);
router.post("/timetable/publish", publishTimetable);

router.get("/fees/summary", getFeesSummary);
router.get("/fees/structures", listFeeStructures);
router.post("/fees/structures", createFeeStructure);
router.put("/fees/structures/:id", updateFeeStructure);
router.delete("/fees/structures/:id", deleteFeeStructure);

router.get("/invoices", listInvoices);
router.post("/invoices", createInvoice);
router.get("/invoices/:id", getInvoiceById);
router.patch("/invoices/:id/status", updateInvoiceStatus);
router.get("/payments", listPayments);
router.post("/payments", createPayment);
router.get("/payments/:id/receipt", getPaymentReceipt);

router.get("/announcements", listAnnouncements);
router.post("/announcements", createAnnouncement);
router.put("/announcements/:id", updateAnnouncement);
router.delete("/announcements/:id", deleteAnnouncement);
router.post("/announcements/:id/send", sendAnnouncement);

router.get("/reports/jobs", listReportJobs);
router.post("/reports/generate", generateReport);
router.get("/audit-logs", listAuditLogs);

router.get("/settings", getSettings);
router.put("/settings", updateSettings);
router.get("/roles", listRoles);
router.post("/roles", createRole);
router.put("/roles/:id", updateRole);
router.delete("/roles/:id", deleteRole);

router.get("/face-checkins", listFaceCheckins);
router.patch("/face-checkins/:id/approve", approveFaceCheckin);
router.patch("/face-checkins/:id/reject", rejectFaceCheckin);

router.get("/ai/faqs", listAiFaqs);
router.post("/ai/faqs", createAiFaq);
router.put("/ai/faqs/:id", updateAiFaq);
router.delete("/ai/faqs/:id", deleteAiFaq);

router.get("/live-classes/sessions", listLiveClassSessions);
router.post("/live-classes/sessions", createLiveClassSession);
router.put("/live-classes/sessions/:id", updateLiveClassSession);
router.post("/live-classes/sessions/:id/end", endLiveClassSession);

router.get("/exams", listExams);
router.post("/exams", createExam);
router.put("/exams/:id", updateExam);
router.delete("/exams/:id", deleteExam);
router.post("/exams/:id/marks", saveExamMarks);
router.post("/exams/:id/publish", publishExam);

module.exports = router;
