class ApiEndpoints {
  ApiEndpoints._();

  // System
  static const String health = '/health';
  static const String ready = '/ready';

  // Auth
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';

  // Parent app
  static const String parentChildren = '/parent/children';
  static const String parentHome = '/parent/home';
  static const String parentAnnouncements = '/parent/announcements';
  static const String parentNotifications = '/parent/notifications';
  static const String parentMarkNotificationsRead =
      '/parent/notifications/mark-all-read';
  static const String parentAttendance = '/parent/attendance';
  static const String parentFees = '/parent/fees';
  static String parentInvoiceById(String invoiceId) =>
      '/parent/invoices/$invoiceId';
  static String parentPayInvoiceBalance(String invoiceId) =>
      '/parent/invoices/$invoiceId/pay-balance';
  static const String parentQuickPayAll = '/parent/fees/quick-pay-all';
  static const String parentTimetable = '/parent/timetable';
  static const String parentMeetingsRequest = '/parent/meetings/request';
  static const String parentProgressReports = '/parent/progress-reports';
  static const String parentLiveClasses = '/parent/live-classes';
  static const String parentExamTimetable = '/parent/exam-timetable';
  static const String parentEventTimetable = '/parent/event-timetable';
  static const String parentProfileHub = '/parent/profile-hub';
  static const String parentLibrary = '/parent/library';
  static const String parentDocuments = '/parent/documents';
  static const String parentSettings = '/parent/settings';

  // Admin app
  static const String dashboardSchoolAdmin = '/dashboard/school-admin';
  static const String schoolApprovalsPendingSummary =
      '/school/approvals/pending-summary';
  static String schoolApprovalDecision(String approvalType, String id) =>
      '/school/approvals/$approvalType/$id/decision';
  static const String schoolNotifications = '/school/notifications';
  static const String schoolNotificationTemplates =
      '/school/notifications/templates';
  static String schoolNotificationTemplateById(String id) =>
      '/school/notifications/templates/$id';
  static const String schoolNotificationLogs = '/school/notifications/logs';
  static const String schoolFeesSnapshot = '/school/fees/snapshot';
  static const String schoolFeesSummary = '/school/fees/summary';
  static const String schoolFeeStructures = '/school/fees/structures';
  static String schoolFeeStructureById(String id) =>
      '/school/fees/structures/$id';
  static const String schoolFeeDiscountRules = '/school/fees/discount-rules';
  static String schoolFeeDiscountRuleById(String id) =>
      '/school/fees/discount-rules/$id';
  static const String schoolFeesDueList = '/school/fees/due-list';
  static const String schoolFeeCollectionReport =
      '/school/fees/reports/collection';
  static const String schoolFeePendingDuesReport =
      '/school/fees/reports/pending-dues';
  static String schoolFeeStudentLedger(String studentId) =>
      '/school/fees/reports/student-ledger/$studentId';
  static const String schoolInvoices = '/school/invoices';
  static String schoolInvoiceById(String id) => '/school/invoices/$id';
  static String schoolInvoiceStatus(String id) => '/school/invoices/$id/status';
  static const String schoolInvoicesBulkGenerate =
      '/school/invoices/bulk-generate';
  static const String schoolPayments = '/school/payments';
  static String schoolPaymentReceipt(String id) =>
      '/school/payments/$id/receipt';
  static String schoolPaymentRefunds(String id) =>
      '/school/payments/$id/refunds';
  static const String schoolAcademicYears = '/school/academic-years';
  static String schoolAcademicYearById(String id) =>
      '/school/academic-years/$id';
  static String schoolAcademicYearActivate(String id) =>
      '/school/academic-years/$id/activate';
  static const String schoolTerms = '/school/terms';
  static String schoolTermById(String id) => '/school/terms/$id';
  static const String schoolSections = '/school/sections';
  static String schoolSectionById(String id) => '/school/sections/$id';
  static const String schoolHolidays = '/school/holidays';
  static String schoolHolidayById(String id) => '/school/holidays/$id';
  static const String schoolAdminUsers = '/school/admin-users';
  static String schoolAdminUserById(String id) => '/school/admin-users/$id';
  static const String schoolRoles = '/school/roles';
  static String schoolRoleById(String id) => '/school/roles/$id';
  static const String schoolPermissions = '/school/permissions';
  static const String schoolPermissionsMatrix = '/school/permissions/matrix';
  static const String schoolDocumentCategories = '/school/document-categories';
  static String schoolDocumentCategoryById(String id) =>
      '/school/document-categories/$id';
  static const String schoolAchievements = '/school/achievements';
  static String schoolAchievementById(String id) => '/school/achievements/$id';
  static const String schoolAiFaqs = '/school/ai/faqs';
  static String schoolAiFaqById(String id) => '/school/ai/faqs/$id';
  static const String schoolHomework = '/school/homework';
  static String schoolHomeworkById(String id) => '/school/homework/$id';
  static String schoolHomeworkSubmit(String id) =>
      '/school/homework/$id/submit';
  static const String schoolFaceCheckins = '/school/face-checkins';
  static String schoolFaceCheckinApprove(String id) =>
      '/school/face-checkins/$id/approve';
  static String schoolFaceCheckinReject(String id) =>
      '/school/face-checkins/$id/reject';
  static const String schoolBackupExports = '/school/backups/exports';
  static const String schoolOfflineSyncRecords = '/school/offline-sync/records';
  static String schoolOfflineSyncRecordById(String id) =>
      '/school/offline-sync/records/$id';
  static const String schoolReportCardTemplates =
      '/school/report-cards/templates';
  static String schoolReportCardTemplateById(String id) =>
      '/school/report-cards/templates/$id';
  static const String schoolAttendanceTrend = '/school/attendance/trend';
  static const String schoolAttendanceOverview = '/school/attendance/overview';
  static const String schoolAttendanceMark = '/school/attendance/mark';
  static const String schoolAttendanceExport = '/school/attendance/export';
  static String schoolAttendanceRecordById(String id) =>
      '/school/attendance/records/$id';
  static const String schoolProfile = '/school/profile';
  static const String schoolProfileMe = '/school/profile/me';
  static const String schoolSettings = '/school/settings';
  static const String schoolAnnouncements = '/school/announcements';
  static String schoolAnnouncementById(String id) =>
      '/school/announcements/$id';
  static String schoolAnnouncementSend(String id) =>
      '/school/announcements/$id/send';
  static const String schoolStudyMaterials = '/school/study-materials';
  static const String schoolAuditLogs = '/school/audit-logs';
  static const String schoolSyllabus = '/school/syllabus';
  static String schoolSyllabusById(String id) => '/school/syllabus/$id';
  static const String schoolLessonPlans = '/school/lesson-plans';
  static String schoolLessonPlanById(String id) => '/school/lesson-plans/$id';
  static const String schoolParents = '/school/parents';
  static String schoolParentById(String id) => '/school/parents/$id';
  static const String schoolParentInvite = '/school/parents/invite';
  static String schoolParentResendOtp(String id) =>
      '/school/parents/$id/resend-otp';
  static const String schoolStaff = '/school/staff';
  static String schoolStaffById(String id) => '/school/staff/$id';
  static const String schoolClasses = '/school/classes';
  static String schoolClassById(String id) => '/school/classes/$id';
  static const String schoolSubjects = '/school/subjects';
  static String schoolSubjectById(String id) => '/school/subjects/$id';
  static const String schoolTimetable = '/school/timetable';
  static String schoolTimetableClass(String classId) =>
      '/school/timetable/class/$classId';
  static const String schoolTimetableConflicts = '/school/timetable/conflicts';
  static const String schoolTimetablePeriods = '/school/timetable/periods';
  static String schoolTimetablePeriodById(String id) =>
      '/school/timetable/periods/$id';
  static String schoolTimetableSlotById(String id) =>
      '/school/timetable/slots/$id';
  static const String schoolTimetablePublish = '/school/timetable/publish';
  static const String schoolLiveClassSessions = '/school/live-classes/sessions';
  static String schoolLiveClassSessionById(String id) =>
      '/school/live-classes/sessions/$id';
  static String schoolLiveClassSessionEnd(String id) =>
      '/school/live-classes/sessions/$id/end';
  static const String schoolExams = '/school/exams';
  static String schoolExamById(String id) => '/school/exams/$id';
  static String schoolExamMarks(String id) => '/school/exams/$id/marks';
  static String schoolExamPublish(String id) => '/school/exams/$id/publish';
  static String schoolExamMarksStatus(String id) =>
      '/school/exams/$id/marks-status';
  static const String schoolLibraryBooks = '/school/library/books';
  static String schoolLibraryBookById(String id) => '/school/library/books/$id';
  static const String schoolLibraryBorrows = '/school/library/borrows';
  static String schoolLibraryBorrowReturn(String id) =>
      '/school/library/borrows/$id/return';
  static const String schoolInventoryItems = '/school/inventory/items';
  static String schoolInventoryItemById(String id) =>
      '/school/inventory/items/$id';
  static const String schoolInventoryTransactions =
      '/school/inventory/transactions';
  static const String schoolTransportRoutes = '/school/transport/routes';
  static String schoolTransportRouteById(String id) =>
      '/school/transport/routes/$id';
  static const String schoolTransportDrivers = '/school/transport/drivers';
  static String schoolTransportDriverById(String id) =>
      '/school/transport/drivers/$id';
  static const String schoolTransportAllocations =
      '/school/transport/allocations';
  static String schoolTransportAllocationById(String id) =>
      '/school/transport/allocations/$id';
  static const String schoolHostelRooms = '/school/hostel/rooms';
  static String schoolHostelRoomById(String id) => '/school/hostel/rooms/$id';
  static const String schoolHostelAllocations = '/school/hostel/allocations';
  static const String schoolHostelAttendance = '/school/hostel/attendance';
  static const String schoolHostelVisitors = '/school/hostel/visitors';
  static const String schoolEvents = '/school/events';
  static String schoolEventById(String id) => '/school/events/$id';
  static String schoolEventRegistrations(String id) =>
      '/school/events/$id/registrations';
  static String schoolEventGallery(String id) => '/school/events/$id/gallery';
  static String schoolEventGalleryImage(String id, String imageId) =>
      '/school/events/$id/gallery/$imageId';
  static const String schoolReportAttendance = '/school/reports/attendance';
  static const String schoolReportFees = '/school/reports/fees';
  static const String schoolReportExamPerformance =
      '/school/reports/exam-performance';
  static const String schoolReportGenerate = '/school/reports/generate';
  static const String schoolReportJobs = '/school/reports/jobs';
  static const String schoolReportStudents = '/school/reports/students';
  static const String schoolAdmissionsApplications =
      '/school/admissions/applications';
  static String schoolAdmissionApplicationById(String id) =>
      '/school/admissions/applications/$id';
  static String schoolAdmissionApplicationStatus(String id) =>
      '/school/admissions/applications/$id/status';
  static String schoolAdmissionApplicationDocuments(String id) =>
      '/school/admissions/applications/$id/documents';
  static String schoolAdmissionApplicationOnboard(String id) =>
      '/school/admissions/applications/$id/onboard';

  // School (used by teacher/staff attendance screens)
  static String schoolTimetableTeacher(String staffId) =>
      '/school/timetable/teacher/$staffId';
  static const String schoolStudents = '/school/students';
  static String schoolStudentById(String id) => '/school/students/$id';
  static String schoolStudentStatus(String id) => '/school/students/$id/status';
  static String schoolStudentMoveClass(String id) =>
      '/school/students/$id/move-class';
  static String schoolStudentDocuments(String id) =>
      '/school/students/$id/documents';
  static String schoolStudentDocumentById(String id, String docId) =>
      '/school/students/$id/documents/$docId';
  static const String schoolStudentsExport = '/school/students/export';
  static const String schoolStudentsImport = '/school/students/import';
  static String schoolStaffDocuments(String id) =>
      '/school/staff/$id/documents';
  static String schoolStaffDocumentById(String id, String docId) =>
      '/school/staff/$id/documents/$docId';
  static const String schoolAttendanceRecords = '/school/attendance/records';
  static const String schoolAttendanceBulkMark = '/school/attendance/bulk-mark';

  // Staff app
  static const String staffDashboard = '/staff/dashboard';
  static const String staffProfile = '/staff/profile';
  static const String staffReports = '/staff/reports';
  static const String staffCommunication = '/staff/communication';
  static const String staffCommunicationMessages =
      '/staff/communication/messages';
  static const String staffCommunicationMeetingNotes =
      '/staff/communication/meeting-notes';
  static const String staffSettings = '/staff/settings';
  static const String staffAiAssist = '/staff/ai/assist';

  // Student app
  static const String studentMeetingsRequest = '/student/meetings/request';
}
