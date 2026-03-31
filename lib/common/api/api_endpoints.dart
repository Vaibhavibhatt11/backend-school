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
  static String parentInvoiceById(String invoiceId) => '/parent/invoices/$invoiceId';
  static String parentPayInvoiceBalance(String invoiceId) => '/parent/invoices/$invoiceId/pay-balance';
  static const String parentQuickPayAll = '/parent/fees/quick-pay-all';
  static const String parentTimetable = '/parent/timetable';
  static const String parentMeetingsRequest = '/parent/meetings/request';
  static const String parentProgressReports = '/parent/progress-reports';
  static const String parentLiveClasses = '/parent/live-classes';
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
  static const String schoolFeesSnapshot = '/school/fees/snapshot';
  static const String schoolFeesSummary = '/school/fees/summary';
  static const String schoolAttendanceTrend = '/school/attendance/trend';
  static const String schoolAttendanceOverview = '/school/attendance/overview';
  static const String schoolProfile = '/school/profile';
  static const String schoolProfileMe = '/school/profile/me';
  static const String schoolSettings = '/school/settings';
  static const String schoolAnnouncements = '/school/announcements';
  static String schoolAnnouncementSend(String id) => '/school/announcements/$id/send';
  static const String schoolStudyMaterials = '/school/study-materials';
  static const String schoolAuditLogs = '/school/audit-logs';
  static const String schoolClasses = '/school/classes';
  static const String schoolSubjects = '/school/subjects';
  static const String schoolReportAttendance = '/school/reports/attendance';
  static const String schoolReportFees = '/school/reports/fees';

  // School (used by teacher/staff attendance screens)
  static String schoolTimetableTeacher(String staffId) => '/school/timetable/teacher/$staffId';
  static const String schoolStudents = '/school/students';
  static const String schoolAttendanceRecords = '/school/attendance/records';
  static const String schoolAttendanceBulkMark = '/school/attendance/bulk-mark';

  // Staff app
  static const String staffDashboard = '/staff/dashboard';
  static const String staffProfile = '/staff/profile';
  static const String staffReports = '/staff/reports';
  static const String staffCommunication = '/staff/communication';
  static const String staffCommunicationMessages = '/staff/communication/messages';
  static const String staffCommunicationMeetingNotes =
      '/staff/communication/meeting-notes';
  static const String staffSettings = '/staff/settings';
  static const String staffAiAssist = '/staff/ai/assist';

  // Student app
  static const String studentMeetingsRequest = '/student/meetings/request';
}

