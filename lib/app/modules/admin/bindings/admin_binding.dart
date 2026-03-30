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
import 'package:erp_frontend/common/services/admin/admin_service.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminShellController>()) {
      Get.put(AdminShellController(), permanent: true);
    }
    if (!Get.isRegistered<AdminDashboardController>()) {
      Get.put(
        AdminDashboardController(Get.find<AdminService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AdminApprovalsController>()) {
      Get.put(
        AdminApprovalsController(Get.find<AdminService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AdminFeeSnapshotController>()) {
      Get.put(
        AdminFeeSnapshotController(Get.find<AdminService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AdminAttendanceController>()) {
      Get.put(
        AdminAttendanceController(Get.find<AdminService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AdminReportsController>()) {
      Get.put(
        AdminReportsController(Get.find<AdminService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AdminNoticeBoardController>()) {
      Get.put(
        AdminNoticeBoardController(Get.find<AdminService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AdminAuditLogsController>()) {
      Get.put(
        AdminAuditLogsController(Get.find<AdminService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AdminProfileController>()) {
      Get.put(
        AdminProfileController(Get.find<AdminService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AdminSettingsController>()) {
      Get.put(
        AdminSettingsController(Get.find<AdminService>()),
        permanent: true,
      );
    }
  }
}
