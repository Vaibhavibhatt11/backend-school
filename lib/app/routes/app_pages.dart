import 'package:erp_frontend/app/modules/admin/views/admin_attendance_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_academics_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_audit_logs_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_admissions_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_fee_snapshot_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_module_detail_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_modules_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_operations_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_people_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_profile_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_resources_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_schedule_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_shell_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_students_view.dart';
import 'package:erp_frontend/app/modules/auth/bindings/auth_binding.dart';
import 'package:erp_frontend/app/modules/auth/views/branch_selection_view.dart';
import 'package:erp_frontend/app/modules/auth/views/forgot_password_view.dart';
import 'package:erp_frontend/app/modules/auth/views/login_view.dart';
import 'package:erp_frontend/app/modules/auth/views/otp_view.dart';
import 'package:erp_frontend/app/modules/auth/views/reset_passowrd_view.dart';
import 'package:erp_frontend/app/modules/auth/views/role_selection_view.dart';
import 'package:erp_frontend/app/modules/auth/views/splash_view.dart';
import 'package:erp_frontend/app/modules/parent/bindings/parent_binding.dart';
import 'package:erp_frontend/app/modules/parent/views/child_switcher_view.dart';
import 'package:erp_frontend/app/modules/parent/views/document_viewer_view.dart';
import 'package:erp_frontend/app/modules/parent/views/invoice_detail_view.dart';
import 'package:erp_frontend/app/modules/parent/views/library_view.dart';
import 'package:erp_frontend/app/modules/parent/views/live_classroom_portal_view.dart';
import 'package:erp_frontend/app/modules/parent/views/notifications_center_view.dart';
import 'package:erp_frontend/app/modules/parent/views/parent_shell_view.dart';
import 'package:erp_frontend/app/modules/parent/views/progress_reports_view.dart';
import 'package:erp_frontend/app/modules/parent/views/school_announcements_view.dart';
import 'package:erp_frontend/app/modules/parent/views/settings_view.dart';
import 'package:erp_frontend/app/modules/teacher/bindings/teacher_binding.dart';
import 'package:erp_frontend/app/modules/teacher/views/announcements_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/mark_attendance_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/notifications_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/student_directory_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/student_profile_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/teacher_shell_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/upload_view.dart';
import 'package:erp_frontend/app/modules/staff/bindings/staff_binding.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_module_detail_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_modules_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_shell_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_feature_detail_view.dart';
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
      page: () => const ParentShellView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_ATTENDANCE,
      page: () => const ParentShellView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_FEES,
      page: () => const ParentShellView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_INVOICE_DETAIL,
      page: () => const InvoiceDetailView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_TIMETABLE,
      page: () => const ParentShellView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_PROFILE,
      page: () => const ParentShellView(),
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
    GetPage(
      name: AppRoutes.TEACHER_HOME,
      page: () => const TeacherShellView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_ATTENDANCE_SELECTOR,
      page: () => const TeacherShellView(),
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
      page: () => const TeacherShellView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_ANNOUNCEMENTS,
      page: () => const AnnouncementsView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_LIVE_CLASS,
      page: () => const TeacherShellView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_UPLOAD,
      page: () => const UploadView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_PROFILE,
      page: () => const TeacherShellView(),
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
      name: AppRoutes.STAFF_FEATURE_DETAIL,
      page: () => const StaffFeatureDetailView(),
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
      name: AppRoutes.ADMIN_ADMISSIONS,
      page: () => const AdminAdmissionsView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_STUDENTS,
      page: () => const AdminStudentsView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_PEOPLE,
      page: () => const AdminPeopleView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_ACADEMICS,
      page: () => const AdminAcademicsView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_SCHEDULE,
      page: () => const AdminScheduleView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_RESOURCES,
      page: () => const AdminResourcesView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_OPERATIONS,
      page: () => const AdminOperationsView(),
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
