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
import 'package:erp_frontend/app/modules/admin/views/admin_staff_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_report_detail_view.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_report_models.dart';
import 'package:erp_frontend/app/modules/auth/bindings/auth_binding.dart';
import 'package:erp_frontend/app/modules/auth/views/branch_selection_view.dart';
import 'package:erp_frontend/app/modules/auth/views/forgot_password_view.dart';
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
import 'package:erp_frontend/app/modules/parent/views/communication_hub_view.dart';
import 'package:erp_frontend/app/modules/parent/views/parent_shell_view.dart';
import 'package:erp_frontend/app/modules/parent/views/progress_reports_view.dart';
import 'package:erp_frontend/app/modules/parent/views/school_announcements_view.dart';
import 'package:erp_frontend/app/modules/parent/views/settings_view.dart';
import 'package:erp_frontend/app/modules/parent/views/monthly_timetable_view.dart';
import 'package:erp_frontend/app/modules/parent/views/exam_timetable_view.dart';
import 'package:erp_frontend/app/modules/parent/views/event_timetable_view.dart';
import 'package:erp_frontend/app/modules/parent/views/events_hub_view.dart';
// import 'package:erp_frontend/app/modules/parent/views/transport_hub_view.dart'; // Transport module commented for now.
import 'package:erp_frontend/app/modules/parent/views/achievements_hub_view.dart';
import 'package:erp_frontend/app/modules/parent/views/finance_hub_view.dart';
import 'package:erp_frontend/app/modules/parent/views/student_id_card_view.dart';
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
import 'package:erp_frontend/app/modules/staff/views/staff_attendance_leave_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_communication_announcements_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_communication_conversation_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_communication_meetings_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_communication_notifications_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_communication_recipients_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_class_teaching_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_lesson_planning_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_homework_assignment_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_exam_assessment_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_performance_monitoring_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_study_material_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_study_material_library_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_study_material_compose_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_study_material_detail_view.dart';
import 'package:erp_frontend/app/modules/staff/views/inventory/staff_inventory_hub_view.dart';
import 'package:erp_frontend/app/modules/staff/views/inventory/staff_inventory_equipment_view.dart';
import 'package:erp_frontend/app/modules/staff/views/inventory/staff_inventory_tracking_view.dart';
import 'package:erp_frontend/app/modules/staff/views/inventory/staff_inventory_purchase_orders_view.dart';
import 'package:erp_frontend/app/modules/librarian/bindings/librarian_binding.dart';
import 'package:erp_frontend/app/modules/librarian/views/librarian_book_catalog_view.dart';
import 'package:erp_frontend/app/modules/librarian/views/librarian_fine_management_view.dart';
import 'package:erp_frontend/app/modules/librarian/views/librarian_issue_return_view.dart';
import 'package:erp_frontend/app/modules/librarian/views/librarian_library_hub_view.dart';
import 'package:erp_frontend/app/modules/librarian/views/librarian_membership_view.dart';
import 'package:erp_frontend/app/modules/hostel_warden/bindings/hostel_warden_binding.dart';
import 'package:erp_frontend/app/modules/hostel_warden/views/hostel_warden_attendance_view.dart';
import 'package:erp_frontend/app/modules/hostel_warden/views/hostel_warden_complaints_view.dart';
import 'package:erp_frontend/app/modules/hostel_warden/views/hostel_warden_hub_view.dart';
import 'package:erp_frontend/app/modules/hostel_warden/views/hostel_warden_room_allocation_view.dart';
import 'package:erp_frontend/app/modules/hostel_warden/views/hostel_warden_visitors_view.dart';

import 'package:erp_frontend/app/modules/admin/views/admin_study_material_compose_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_study_material_detail_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_study_material_library_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_study_material_view.dart';
import 'package:erp_frontend/app/modules/admin/views/events/admin_events_hub_view.dart';
import 'package:erp_frontend/app/modules/admin/views/events/admin_events_calendar_view.dart';
import 'package:erp_frontend/app/modules/admin/views/events/admin_events_competitions_view.dart';
import 'package:erp_frontend/app/modules/admin/views/events/admin_events_registrations_view.dart';
import 'package:erp_frontend/app/modules/admin/views/events/admin_events_reports_view.dart';
import 'package:erp_frontend/modules/auth/login/login_binding.dart';
import 'package:erp_frontend/modules/auth/login/login_screen.dart';
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
      page: () => const LoginScreen(),
      binding: LoginBinding(),
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
      name: AppRoutes.PARENT_TIMETABLE_MONTHLY,
      page: () => const MonthlyTimetableView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_EXAM_TIMETABLE,
      page: () => const ExamTimetableView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_EVENT_TIMETABLE,
      page: () => const EventTimetableView(),
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
      name: AppRoutes.PARENT_STUDENT_ID_CARD,
      page: () => const StudentIdCardView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_NOTIFICATIONS,
      page: () => const NotificationsCenterView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_COMMUNICATION,
      page: () => const CommunicationHubView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_EVENTS_HUB,
      page: () => const EventsHubView(),
      binding: ParentBinding(),
    ),
    // Transport module route commented for now.
    // GetPage(
    //   name: AppRoutes.PARENT_TRANSPORT,
    //   page: () => const TransportHubView(),
    //   binding: ParentBinding(),
    // ),
    GetPage(
      name: AppRoutes.PARENT_ACHIEVEMENTS,
      page: () => const AchievementsHubView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: AppRoutes.PARENT_FINANCE_HUB,
      page: () => const FinanceHubView(),
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
      name: AppRoutes.STAFF_ATTENDANCE_LEAVE,
      page: () => const StaffAttendanceLeaveView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_CLASS_TEACHING,
      page: () => const StaffClassTeachingView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_LESSON_PLANNING,
      page: () => const StaffLessonPlanningView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_HOMEWORK_ASSIGNMENT,
      page: () => const StaffHomeworkAssignmentView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_EXAM_ASSESSMENT,
      page: () => const StaffExamAssessmentView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_PERFORMANCE_MONITORING,
      page: () => const StaffPerformanceMonitoringView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_STUDY_MATERIAL,
      page: () => const StaffStudyMaterialView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_STUDY_MATERIAL_LIBRARY,
      page: () => const StaffStudyMaterialLibraryView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_STUDY_MATERIAL_COMPOSER,
      page: () => const StaffStudyMaterialComposeView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_STUDY_MATERIAL_DETAIL,
      page: () => const StaffStudyMaterialDetailView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_COMMUNICATION_RECIPIENTS,
      page: () => const StaffCommunicationRecipientsView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_COMMUNICATION_CONVERSATION,
      page: () => const StaffCommunicationConversationView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_COMMUNICATION_ANNOUNCEMENTS,
      page: () => const StaffCommunicationAnnouncementsView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_COMMUNICATION_NOTIFICATIONS,
      page: () => const StaffCommunicationNotificationsView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_COMMUNICATION_MEETINGS,
      page: () => const StaffCommunicationMeetingsView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_INVENTORY_HUB,
      page: () => const StaffInventoryHubView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_INVENTORY_EQUIPMENT,
      page: () => const StaffInventoryEquipmentView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_INVENTORY_TRACKING,
      page: () => const StaffInventoryTrackingView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.STAFF_INVENTORY_PURCHASE_ORDERS,
      page: () => const StaffInventoryPurchaseOrdersView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.LIBRARIAN_HOME,
      page: () => const LibrarianLibraryHubView(),
      binding: LibrarianBinding(),
    ),
    GetPage(
      name: AppRoutes.LIBRARIAN_BOOK_CATALOG,
      page: () => const LibrarianBookCatalogView(),
      binding: LibrarianBinding(),
    ),
    GetPage(
      name: AppRoutes.LIBRARIAN_BOOK_ISSUE,
      page: () => const LibrarianIssueReturnView(returnOnly: false),
      binding: LibrarianBinding(),
    ),
    GetPage(
      name: AppRoutes.LIBRARIAN_BOOK_RETURN,
      page: () => const LibrarianIssueReturnView(returnOnly: true),
      binding: LibrarianBinding(),
    ),
    GetPage(
      name: AppRoutes.LIBRARIAN_FINE_MANAGEMENT,
      page: () => const LibrarianFineManagementView(),
      binding: LibrarianBinding(),
    ),
    GetPage(
      name: AppRoutes.LIBRARIAN_MEMBERSHIP,
      page: () => const LibrarianMembershipView(),
      binding: LibrarianBinding(),
    ),
    GetPage(
      name: AppRoutes.HOSTEL_WARDEN_HOME,
      page: () => const HostelWardenHubView(),
      binding: HostelWardenBinding(),
    ),
    GetPage(
      name: AppRoutes.HOSTEL_WARDEN_ROOM_ALLOCATION,
      page: () => const HostelWardenRoomAllocationView(),
      binding: HostelWardenBinding(),
    ),
    GetPage(
      name: AppRoutes.HOSTEL_WARDEN_ATTENDANCE,
      page: () => const HostelWardenAttendanceView(),
      binding: HostelWardenBinding(),
    ),
    GetPage(
      name: AppRoutes.HOSTEL_WARDEN_VISITORS,
      page: () => const HostelWardenVisitorsView(),
      binding: HostelWardenBinding(),
    ),
    GetPage(
      name: AppRoutes.HOSTEL_WARDEN_COMPLAINTS,
      page: () => const HostelWardenComplaintsView(),
      binding: HostelWardenBinding(),
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
      name: AppRoutes.ADMIN_STAFF,
      page: () => const AdminStaffView(),
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
    GetPage(
      name: AppRoutes.ADMIN_STUDY_MATERIAL,
      page: () => const AdminStudyMaterialView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_STUDY_MATERIAL_LIBRARY,
      page: () => const AdminStudyMaterialLibraryView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_STUDY_MATERIAL_COMPOSER,
      page: () => const AdminStudyMaterialComposeView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_STUDY_MATERIAL_DETAIL,
      page: () => const AdminStudyMaterialDetailView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_EVENTS_HUB,
      page: () => const AdminEventsHubView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_EVENTS_CALENDAR,
      page: () => const AdminEventsCalendarView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_EVENTS_COMPETITIONS,
      page: () => const AdminEventsCompetitionsView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_EVENTS_REGISTRATIONS,
      page: () => const AdminEventsRegistrationsView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_EVENTS_REPORTS,
      page: () => const AdminEventsReportsView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_REPORTS_DETAIL,
      page: () {
        final kind = Get.arguments['kind'] as AdminReportKind;
        return AdminReportDetailView(kind: kind);
      },
      binding: AdminBinding(),
    ),
  ];
}
