const router = require("express").Router();
const {
  listParents,
  getParentById,
  createParent,
  updateParent,
  inviteParent,
  resendParentOtp,
  listStaff,
  getStaffById,
  createStaff,
  updateStaff,
  deleteStaff,
  listRoles,
  createRole,
  updateRole,
  deleteRole,
  listAdminUsers,
  createAdminUser,
  updateAdminUser,
  getPermissionsList,
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
  listAttendanceRecords,
  updateAttendanceRecord,
  exportAttendance,
} = require("./school.academic.core.handlers");
const {
  getTimetable,
  createTimetableSlot,
  updateTimetableSlot,
  deleteTimetableSlot,
  publishTimetable,
  getTimetableByTeacher,
  getTimetableByClass,
  getTimetableConflicts,
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
  bulkGenerateInvoices,
  getDueList,
  getCollectionReport,
  getPendingDuesReport,
  getStudentLedger,
  listReportJobs,
  generateReport,
} = require("./school.finance.handlers");
const {
  listAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
  sendAnnouncement,
  getAnnouncementById,
  listAuditLogs,
  getSettings,
  updateSettings,
  getSchoolProfile,
  updateSchoolProfile,
  listFaceCheckins,
  approveFaceCheckin,
  rejectFaceCheckin,
} = require("./school.misc.handlers");
const {
  getProfileMe,
  getPendingApprovalsSummary,
  decidePendingApproval,
  getSchoolNotifications,
  getFeesSnapshot,
  getAttendanceTrend,
} = require("./school.admin.handlers");
const {
  listExams,
  createExam,
  updateExam,
  deleteExam,
  saveExamMarks,
  publishExam,
  getExamMarksStatus,
} = require("./school.exams.handlers");
const {
  listAcademicYears,
  createAcademicYear,
  updateAcademicYear,
  activateAcademicYear,
  deleteAcademicYear,
  listTerms,
  createTerm,
  updateTerm,
  deleteTerm,
  listHolidays,
  createHoliday,
  updateHoliday,
  deleteHoliday,
  listSections,
  createSection,
  updateSection,
  deleteSection,
  getPermissionMatrix,
  updatePermissionMatrix,
  listStaffDocuments,
  addStaffDocument,
  deleteStaffDocument,
  listTimetablePeriods,
  createTimetablePeriod,
  updateTimetablePeriod,
  deleteTimetablePeriod,
  listFeeDiscountRules,
  createFeeDiscountRule,
  updateFeeDiscountRule,
  deleteFeeDiscountRule,
  listPaymentRefunds,
  createPaymentRefund,
  listReportCardTemplates,
  createReportCardTemplate,
  updateReportCardTemplate,
  deleteReportCardTemplate,
  listNotificationTemplates,
  createNotificationTemplate,
  updateNotificationTemplate,
  deleteNotificationTemplate,
  listNotificationLogs,
  listDocumentCategories,
  createDocumentCategory,
  updateDocumentCategory,
  deleteDocumentCategory,
  listBackupExportJobs,
  createBackupExportJob,
  listLibraryBooks,
  createLibraryBook,
  updateLibraryBook,
  deleteLibraryBook,
  listLibraryBorrows,
  createLibraryBorrow,
  returnLibraryBorrow,
  listInventoryItems,
  createInventoryItem,
  updateInventoryItem,
  deleteInventoryItem,
  listInventoryTransactions,
  createInventoryTransaction,
  listOfflineSyncRecords,
  createOfflineSyncRecord,
  updateOfflineSyncRecord,
} = require("./school.advanced.handlers");
const { reportStudents, reportAttendance, reportFees, reportExamPerformance } = require("./school.reports.handlers");
const {
  listApplications,
  getApplicationById,
  createApplication,
  updateApplicationStatus,
  addApplicationDocument,
  onboardApplication,
} = require("./school.admissions.handlers");
const {
  listRoutes,
  createRoute,
  updateRoute,
  deleteRoute,
  listDrivers,
  createDriver,
  listAllocations,
  createAllocation,
  updateAllocation,
  deleteAllocation,
} = require("./school.transport.handlers");
const {
  listRooms,
  createRoom,
  updateRoom,
  deleteRoom,
  listAllocations: listHostelAllocations,
  createAllocation: createHostelAllocation,
  listAttendance: listHostelAttendance,
  markHostelAttendance,
  listVisitors,
  createVisitor,
} = require("./school.hostel.handlers");
const {
  listEvents,
  getEventById,
  createEvent,
  updateEvent,
  deleteEvent,
  listRegistrations,
  registerForEvent,
  addGalleryImage,
  deleteGalleryImage,
} = require("./school.events.handlers");
const {
  listHomework,
  getHomeworkById,
  createHomework,
  updateHomework,
  deleteHomework,
  submitHomework,
  listStudyMaterials,
  createStudyMaterial,
  updateStudyMaterial,
  deleteStudyMaterial,
  listAchievements,
  createAchievement,
  deleteAchievement,
} = require("./school.homework.handlers");

router.get("/profile", getSchoolProfile);
router.get("/profile/me", getProfileMe);
router.put("/profile", updateSchoolProfile);
router.get("/approvals/pending-summary", getPendingApprovalsSummary);
router.patch("/approvals/:approvalType/:id/decision", decidePendingApproval);
router.get("/notifications", getSchoolNotifications);

router.get("/permissions", getPermissionsList);
router.get("/admin-users", listAdminUsers);
router.post("/admin-users", createAdminUser);
router.put("/admin-users/:id", updateAdminUser);

router.get("/parents", listParents);
router.get("/parents/:id", getParentById);
router.post("/parents", createParent);
router.put("/parents/:id", updateParent);
router.post("/parents/invite", inviteParent);
router.post("/parents/:id/resend-otp", resendParentOtp);

router.get("/staff", listStaff);
router.get("/staff/:id", getStaffById);
router.post("/staff", createStaff);
router.put("/staff/:id", updateStaff);
router.delete("/staff/:id", deleteStaff);
router.get("/staff/:id/documents", listStaffDocuments);
router.post("/staff/:id/documents", addStaffDocument);
router.delete("/staff/:id/documents/:docId", deleteStaffDocument);

router.get("/classes", listClasses);
router.post("/classes", createClass);
router.put("/classes/:id", updateClass);
router.delete("/classes/:id", deleteClass);

router.get("/sections", listSections);
router.post("/sections", createSection);
router.put("/sections/:id", updateSection);
router.delete("/sections/:id", deleteSection);

router.get("/academic-years", listAcademicYears);
router.post("/academic-years", createAcademicYear);
router.put("/academic-years/:id", updateAcademicYear);
router.patch("/academic-years/:id/activate", activateAcademicYear);
router.delete("/academic-years/:id", deleteAcademicYear);

router.get("/terms", listTerms);
router.post("/terms", createTerm);
router.put("/terms/:id", updateTerm);
router.delete("/terms/:id", deleteTerm);

router.get("/holidays", listHolidays);
router.post("/holidays", createHoliday);
router.put("/holidays/:id", updateHoliday);
router.delete("/holidays/:id", deleteHoliday);

router.get("/permissions/matrix", getPermissionMatrix);
router.put("/permissions/matrix", updatePermissionMatrix);

router.get("/subjects", listSubjects);
router.post("/subjects", createSubject);
router.put("/subjects/:id", updateSubject);
router.delete("/subjects/:id", deleteSubject);

router.get("/attendance/overview", attendanceOverview);
router.get("/attendance/trend", getAttendanceTrend);
router.get("/attendance/records", listAttendanceRecords);
router.put("/attendance/records/:id", updateAttendanceRecord);
router.get("/attendance/export", exportAttendance);
router.post("/attendance/mark", markAttendance);
router.post("/attendance/bulk-mark", bulkMarkAttendance);

router.get("/timetable", getTimetable);
router.get("/timetable/teacher/:staffId", getTimetableByTeacher);
router.get("/timetable/class/:classId", getTimetableByClass);
router.get("/timetable/conflicts", getTimetableConflicts);
router.post("/timetable/slots", createTimetableSlot);
router.put("/timetable/slots/:id", updateTimetableSlot);
router.delete("/timetable/slots/:id", deleteTimetableSlot);
router.post("/timetable/publish", publishTimetable);
router.get("/timetable/periods", listTimetablePeriods);
router.post("/timetable/periods", createTimetablePeriod);
router.put("/timetable/periods/:id", updateTimetablePeriod);
router.delete("/timetable/periods/:id", deleteTimetablePeriod);

router.get("/fees/summary", getFeesSummary);
router.get("/fees/snapshot", getFeesSnapshot);
router.get("/fees/structures", listFeeStructures);
router.post("/fees/structures", createFeeStructure);
router.put("/fees/structures/:id", updateFeeStructure);
router.delete("/fees/structures/:id", deleteFeeStructure);
router.get("/fees/discount-rules", listFeeDiscountRules);
router.post("/fees/discount-rules", createFeeDiscountRule);
router.put("/fees/discount-rules/:id", updateFeeDiscountRule);
router.delete("/fees/discount-rules/:id", deleteFeeDiscountRule);

router.get("/invoices", listInvoices);
router.post("/invoices", createInvoice);
router.post("/invoices/bulk-generate", bulkGenerateInvoices);
router.get("/invoices/:id", getInvoiceById);
router.patch("/invoices/:id/status", updateInvoiceStatus);
router.get("/payments", listPayments);
router.post("/payments", createPayment);
router.get("/payments/:id/receipt", getPaymentReceipt);
router.get("/payments/:id/refunds", listPaymentRefunds);
router.post("/payments/:id/refunds", createPaymentRefund);
router.get("/fees/due-list", getDueList);
router.get("/fees/reports/collection", getCollectionReport);
router.get("/fees/reports/pending-dues", getPendingDuesReport);
router.get("/fees/reports/student-ledger/:studentId", getStudentLedger);

router.get("/announcements", listAnnouncements);
router.get("/announcements/:id", getAnnouncementById);
router.post("/announcements", createAnnouncement);
router.put("/announcements/:id", updateAnnouncement);
router.delete("/announcements/:id", deleteAnnouncement);
router.post("/announcements/:id/send", sendAnnouncement);

router.get("/reports/jobs", listReportJobs);
router.post("/reports/generate", generateReport);
router.get("/audit-logs", listAuditLogs);
router.get("/report-cards/templates", listReportCardTemplates);
router.post("/report-cards/templates", createReportCardTemplate);
router.put("/report-cards/templates/:id", updateReportCardTemplate);
router.delete("/report-cards/templates/:id", deleteReportCardTemplate);

router.get("/settings", getSettings);
router.put("/settings", updateSettings);
router.get("/roles", listRoles);
router.post("/roles", createRole);
router.put("/roles/:id", updateRole);
router.delete("/roles/:id", deleteRole);

router.get("/face-checkins", listFaceCheckins);
router.patch("/face-checkins/:id/approve", approveFaceCheckin);
router.patch("/face-checkins/:id/reject", rejectFaceCheckin);

router.get("/notifications/templates", listNotificationTemplates);
router.post("/notifications/templates", createNotificationTemplate);
router.put("/notifications/templates/:id", updateNotificationTemplate);
router.delete("/notifications/templates/:id", deleteNotificationTemplate);
router.get("/notifications/logs", listNotificationLogs);

router.get("/document-categories", listDocumentCategories);
router.post("/document-categories", createDocumentCategory);
router.put("/document-categories/:id", updateDocumentCategory);
router.delete("/document-categories/:id", deleteDocumentCategory);

router.get("/backups/exports", listBackupExportJobs);
router.post("/backups/exports", createBackupExportJob);

router.get("/library/books", listLibraryBooks);
router.post("/library/books", createLibraryBook);
router.put("/library/books/:id", updateLibraryBook);
router.delete("/library/books/:id", deleteLibraryBook);
router.get("/library/borrows", listLibraryBorrows);
router.post("/library/borrows", createLibraryBorrow);
router.patch("/library/borrows/:id/return", returnLibraryBorrow);

router.get("/inventory/items", listInventoryItems);
router.post("/inventory/items", createInventoryItem);
router.put("/inventory/items/:id", updateInventoryItem);
router.delete("/inventory/items/:id", deleteInventoryItem);
router.get("/inventory/transactions", listInventoryTransactions);
router.post("/inventory/transactions", createInventoryTransaction);

router.get("/offline-sync/records", listOfflineSyncRecords);
router.post("/offline-sync/records", createOfflineSyncRecord);
router.patch("/offline-sync/records/:id", updateOfflineSyncRecord);

router.get("/live-classes/sessions", listLiveClassSessions);
router.post("/live-classes/sessions", createLiveClassSession);
router.put("/live-classes/sessions/:id", updateLiveClassSession);
router.post("/live-classes/sessions/:id/end", endLiveClassSession);

router.get("/exams", listExams);
router.post("/exams", createExam);
router.get("/exams/:id/marks-status", getExamMarksStatus);
router.put("/exams/:id", updateExam);
router.delete("/exams/:id", deleteExam);
router.post("/exams/:id/marks", saveExamMarks);
router.post("/exams/:id/publish", publishExam);

router.get("/reports/students", reportStudents);
router.get("/reports/attendance", reportAttendance);
router.get("/reports/fees", reportFees);
router.get("/reports/exam-performance", reportExamPerformance);

// Admissions
router.get("/admissions/applications", listApplications);
router.get("/admissions/applications/:id", getApplicationById);
router.post("/admissions/applications", createApplication);
router.patch("/admissions/applications/:id/status", updateApplicationStatus);
router.post("/admissions/applications/:id/documents", addApplicationDocument);
router.post("/admissions/applications/:id/onboard", onboardApplication);

// Transport
router.get("/transport/routes", listRoutes);
router.post("/transport/routes", createRoute);
router.put("/transport/routes/:id", updateRoute);
router.delete("/transport/routes/:id", deleteRoute);
router.get("/transport/drivers", listDrivers);
router.post("/transport/drivers", createDriver);
router.get("/transport/allocations", listAllocations);
router.post("/transport/allocations", createAllocation);
router.put("/transport/allocations/:id", updateAllocation);
router.delete("/transport/allocations/:id", deleteAllocation);

// Hostel
router.get("/hostel/rooms", listRooms);
router.post("/hostel/rooms", createRoom);
router.put("/hostel/rooms/:id", updateRoom);
router.delete("/hostel/rooms/:id", deleteRoom);
router.get("/hostel/allocations", listHostelAllocations);
router.post("/hostel/allocations", createHostelAllocation);
router.get("/hostel/attendance", listHostelAttendance);
router.post("/hostel/attendance", markHostelAttendance);
router.get("/hostel/visitors", listVisitors);
router.post("/hostel/visitors", createVisitor);

// Events
router.get("/events", listEvents);
router.get("/events/:id", getEventById);
router.post("/events", createEvent);
router.put("/events/:id", updateEvent);
router.delete("/events/:id", deleteEvent);
router.get("/events/:id/registrations", listRegistrations);
router.post("/events/:id/registrations", registerForEvent);
router.post("/events/:id/gallery", addGalleryImage);
router.delete("/events/:id/gallery/:imageId", deleteGalleryImage);

// Homework, study materials, achievements
router.get("/homework", listHomework);
router.get("/homework/:id", getHomeworkById);
router.post("/homework", createHomework);
router.put("/homework/:id", updateHomework);
router.delete("/homework/:id", deleteHomework);
router.post("/homework/:id/submit", submitHomework);
router.get("/study-materials", listStudyMaterials);
router.post("/study-materials", createStudyMaterial);
router.put("/study-materials/:id", updateStudyMaterial);
router.delete("/study-materials/:id", deleteStudyMaterial);
router.get("/achievements", listAchievements);
router.post("/achievements", createAchievement);
router.delete("/achievements/:id", deleteAchievement);

module.exports = router;
