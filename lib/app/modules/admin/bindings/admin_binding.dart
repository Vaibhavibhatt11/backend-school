import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/admin_approvals_controller.dart';
import '../controllers/admin_fee_snapshot_controller.dart';
import '../controllers/admin_attendance_controller.dart';
import '../controllers/admin_reports_controller.dart';
import '../controllers/admin_notice_board_controller.dart';
import '../controllers/admin_audit_logs_controller.dart';
import '../controllers/admin_profile_controller.dart';
import '../controllers/admin_settings_controller.dart';
import '../controllers/admin_shell_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminShellController>()) {
      Get.put(AdminShellController(), permanent: true);
    }
    if (!Get.isRegistered<AdminDashboardController>()) {
      Get.put(AdminDashboardController(), permanent: true);
    }
    if (!Get.isRegistered<AdminApprovalsController>()) {
      Get.put(AdminApprovalsController(), permanent: true);
    }
    if (!Get.isRegistered<AdminFeeSnapshotController>()) {
      Get.put(AdminFeeSnapshotController(), permanent: true);
    }
    if (!Get.isRegistered<AdminAttendanceController>()) {
      Get.put(AdminAttendanceController(), permanent: true);
    }
    if (!Get.isRegistered<AdminReportsController>()) {
      Get.put(AdminReportsController(), permanent: true);
    }
    if (!Get.isRegistered<AdminNoticeBoardController>()) {
      Get.put(AdminNoticeBoardController(), permanent: true);
    }
    if (!Get.isRegistered<AdminAuditLogsController>()) {
      Get.put(AdminAuditLogsController(), permanent: true);
    }
    if (!Get.isRegistered<AdminProfileController>()) {
      Get.put(AdminProfileController(), permanent: true);
    }
    if (!Get.isRegistered<AdminSettingsController>()) {
      Get.put(AdminSettingsController(), permanent: true);
    }
  }
}
