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

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminDashboardController());
    Get.lazyPut(() => AdminApprovalsController());
    Get.lazyPut(() => AdminFeeSnapshotController());
    Get.lazyPut(() => AdminAttendanceController());
    Get.lazyPut(() => AdminReportsController());
    Get.lazyPut(() => AdminNoticeBoardController());
    Get.lazyPut(() => AdminAuditLogsController());
    Get.lazyPut(() => AdminProfileController());
    Get.lazyPut(() => AdminSettingsController());
  }
}
