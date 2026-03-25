class ApiEndpoints {
  ApiEndpoints._();

  // System
  static const String health = '/health';
  static const String ready = '/ready';

  // Auth
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';

  // Parent app
  static const String parentChildren = '/parent/children';
  static const String parentHome = '/parent/home';
  static const String parentAnnouncements = '/parent/announcements';
  static const String parentNotifications = '/parent/notifications';
  static const String parentAttendance = '/parent/attendance';
  static const String parentFees = '/parent/fees';
  static String parentInvoiceById(String invoiceId) => '/parent/invoices/$invoiceId';
  static const String parentTimetable = '/parent/timetable';
  static const String parentProgressReports = '/parent/progress-reports';
  static const String parentLiveClasses = '/parent/live-classes';
  static const String parentProfileHub = '/parent/profile-hub';
  static const String parentLibrary = '/parent/library';
  static const String parentDocuments = '/parent/documents';
  static const String parentAiAsk = '/parent/ai/ask';
  static const String parentAiCareer = '/parent/ai/career';
  static const String parentSettings = '/parent/settings';
}

