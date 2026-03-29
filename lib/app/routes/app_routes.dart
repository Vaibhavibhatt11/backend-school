part of 'app_pages.dart';

abstract class AppRoutes {
  // Auth
  static const SPLASH = '/splash';
  static const BRANCH_SELECTION = '/branch-selection';
  static const LOGIN = '/login';
  static const OTP = '/otp';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const RESET_PASSWORD = '/reset-password';
  static const ROLE_SELECTION = '/role-selection';

  // Parent Module
  static const PARENT_HOME = '/parent-home';
  static const PARENT_ATTENDANCE = '/parent-attendance';
  static const PARENT_FEES = '/parent-fees';
  static const PARENT_INVOICE_DETAIL = '/parent-invoice-detail';
  static const PARENT_TIMETABLE = '/parent-timetable';
  static const PARENT_PROFILE = '/parent-profile';
  static const PARENT_CHILD_SWITCHER = '/parent-child-switcher';
  static const PARENT_ANNOUNCEMENTS = '/parent-announcements';
  static const PARENT_AI_ASSISTANT = '/parent-ai-assistant';
  static const PARENT_PERFORMANCE = '/parent-performance';
  static const PARENT_LIVE_CLASS = '/parent-live-class';
  static const PARENT_LIBRARY = '/parent-library';
  static const PARENT_DOCUMENT_VIEWER = '/parent-document-viewer';
  static const PARENT_NOTIFICATIONS = '/parent-notifications';
  static const PARENT_SETTINGS = '/parent-settings';

  // Teacher/Admin (placeholders)
  // Teacher Module
  static const TEACHER_HOME = '/teacher-home';
  static const TEACHER_ATTENDANCE_SELECTOR = '/teacher-attendance-selector';
  static const TEACHER_MARK_ATTENDANCE = '/teacher-mark-attendance';
  static const TEACHER_STUDENT_DIRECTORY = '/teacher-student-directory';
  static const TEACHER_STUDENT_PROFILE = '/teacher-student-profile';
  static const TEACHER_TIMETABLE = '/teacher-timetable';
  static const TEACHER_ANNOUNCEMENTS = '/teacher-announcements';
  static const TEACHER_LIVE_CLASS = '/teacher-live-class';
  static const TEACHER_UPLOAD = '/teacher-upload';
  static const TEACHER_PROFILE = '/teacher-profile';
  static const TEACHER_AI_ASSISTANT = '/teacher-ai-assistant';
  static const TEACHER_NOTIFICATIONS = '/teacher-notifications';

  // Staff Module
  static const STAFF_HOME = '/staff-home';
  static const STAFF_MODULES = '/staff-modules';
  static const STAFF_MODULE_DETAIL = '/staff-module-detail';

  // Admin Module
  static const ADMIN_HOME = '/admin-dashboard';
  static const ADMIN_APPROVALS = '/admin-approvals';
  static const ADMIN_FEE_SNAPSHOT = '/admin-fee-snapshot';
  static const ADMIN_ATTENDANCE = '/admin-attendance';
  static const ADMIN_REPORTS = '/admin-reports';
  static const ADMIN_NOTICE_BOARD = '/admin-notice-board';
  static const ADMIN_AUDIT_LOGS = '/admin-audit-logs';
  static const ADMIN_PROFILE = '/admin-profile';
  static const ADMIN_SETTINGS = '/admin-settings';
  static const ADMIN_MODULES = '/admin-modules';
  static const ADMIN_MODULE_DETAIL = '/admin-module-detail';
  static const ADMIN_FEATURE_DETAIL = '/admin-feature-detail';
}
