import 'package:erp_frontend/app/modules/admin/views/admin_attendance_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_audit_logs_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_shell_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_fee_snapshot_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_profile_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_module_detail_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_modules_view.dart';
import 'package:erp_frontend/app/modules/auth/bindings/auth_binding.dart';
import 'package:erp_frontend/app/modules/auth/views/branch_selection_view.dart';
import 'package:erp_frontend/app/modules/auth/views/forgot_password_view.dart';
import 'package:erp_frontend/app/modules/auth/views/login_view.dart';
import 'package:erp_frontend/app/modules/auth/views/otp_view.dart';
import 'package:erp_frontend/app/modules/auth/views/reset_passowrd_view.dart';
import 'package:erp_frontend/app/modules/auth/views/role_selection_view.dart';
import 'package:erp_frontend/app/modules/auth/views/splash_view.dart';
import 'package:erp_frontend/app/modules/parent/bindings/parent_binding.dart';
import 'package:erp_frontend/app/modules/parent/views/ai_assistant_view.dart';
import 'package:erp_frontend/app/modules/parent/views/attendance_tracker_view.dart';
import 'package:erp_frontend/app/modules/parent/views/child_switcher_view.dart';
import 'package:erp_frontend/app/modules/parent/views/daily_timetable_view.dart';
import 'package:erp_frontend/app/modules/parent/views/document_viewer_view.dart';
import 'package:erp_frontend/app/modules/parent/views/fees_management_view.dart';
import 'package:erp_frontend/app/modules/parent/views/invoice_detail_view.dart';
import 'package:erp_frontend/app/modules/parent/views/library_view.dart';
import 'package:erp_frontend/app/modules/parent/views/live_classroom_portal_view.dart';
import 'package:erp_frontend/app/modules/parent/views/notifications_center_view.dart';
import 'package:erp_frontend/app/modules/parent/views/parent_home_view.dart';
import 'package:erp_frontend/app/modules/parent/views/progress_reports_view.dart';
import 'package:erp_frontend/app/modules/parent/views/school_announcements_view.dart';
import 'package:erp_frontend/app/modules/parent/views/settings_view.dart';
import 'package:erp_frontend/app/modules/parent/views/student_profile_hub_view.dart';
import 'package:erp_frontend/app/modules/teacher/bindings/teacher_binding.dart';
import 'package:erp_frontend/app/modules/teacher/views/ai_assistant_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/announcements_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/attendance_selector_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/live_class_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/mark_attendance_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/notifications_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/student_directory_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/student_profile_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/teacher_home_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/teacher_profile_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/timetable_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/upload_view.dart';
import 'package:erp_frontend/app/modules/staff/bindings/staff_binding.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_module_detail_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_modules_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_shell_view.dart';
import 'package:get/get.dart';

import '../modules/admin/bindings/admin_binding.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.BRANCH_SELECTION,
      page: () => const BranchSelectionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.OTP,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.ROLE_SELECTION,
      page: () => const RoleSelectionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_HOME,
      page: () => const ParentHomeView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_ATTENDANCE,
      page: () => const AttendanceTrackerView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_FEES,
      page: () => const FeesManagementView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_INVOICE_DETAIL,
      page: () => const InvoiceDetailView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_TIMETABLE,
      page: () => const DailyTimetableView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_PROFILE,
      page: () => const StudentProfileHubView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_CHILD_SWITCHER,
      page: () => const ChildSwitcherView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_ANNOUNCEMENTS,
      page: () => const SchoolAnnouncementsView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_AI_ASSISTANT,
      page: () => const AIAssistantView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_PERFORMANCE,
      page: () => const ProgressReportsView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_LIVE_CLASS,
      page: () => const LiveClassroomPortalView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_LIBRARY,
      page: () => const LibraryView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_DOCUMENT_VIEWER,
      page: () => const DocumentViewerView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_NOTIFICATIONS,
      page: () => const NotificationsCenterView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_SETTINGS,
      page: () => const SettingsView(),
      binding: ParentBinding(),
    ),
    // teacher routes (placeholders)
    GetPage(
      name: AppRoutes.TEACHER_HOME,
      page: () => const TeacherHomeView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_ATTENDANCE_SELECTOR,
      page: () => const AttendanceSelectorView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_MARK_ATTENDANCE,
      page: () => const MarkAttendanceView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_STUDENT_DIRECTORY,
      page: () => const StudentDirectoryView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_STUDENT_PROFILE,
      page: () => const StudentProfileView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_TIMETABLE,
      page: () => const TimetableView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_ANNOUNCEMENTS,
      page: () => const AnnouncementsView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_LIVE_CLASS,
      page: () => const LiveClassView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_UPLOAD,
      page: () => const UploadView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_PROFILE,
      page: () => const TeacherProfileView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_AI_ASSISTANT,
      page: () => const AiAssistantView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_HOME,
      page: () => const StaffShellView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_MODULES,
      page: () => const StaffModulesView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_MODULE_DETAIL,
      page: () => const StaffModuleDetailView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_HOME,
      page: () => const AdminShellView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_APPROVALS,
      page: () => const AdminShellView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_FEE_SNAPSHOT,
      page: () => const AdminFeeSnapshotView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_ATTENDANCE,
      page: () => const AdminAttendanceView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_REPORTS,
      page: () => const AdminShellView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_NOTICE_BOARD,
      page: () => const AdminShellView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_AUDIT_LOGS,
      page: () => const AdminAuditLogsView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_PROFILE,
      page: () => const AdminProfileView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_SETTINGS,
      page: () => const AdminShellView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_MODULES,
      page: () => const AdminModulesView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_MODULE_DETAIL,
      page: () => const AdminModuleDetailView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_FEATURE_DETAIL,
      page: () => const AdminFeatureDetailView(),
      binding: AdminBinding(),
    ),
  ];
}
