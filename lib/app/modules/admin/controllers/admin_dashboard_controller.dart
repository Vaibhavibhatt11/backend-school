import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final quickActions = [
    'New Admission',
    'Broadcast',
    'Mark Leave',
    'Collect Fee',
  ];
  final totalStudents = 1248;
  final teacherPresence = 98;
  final teacherPresent = 78;
  final teacherTotal = 80;
  final pendingApprovals = 12;
  final attendanceTrend = [88, 75, 82, 55, 92, 98, 88]; // Mon-Sun

  void onQuickActionTap(String action) {
    Get.snackbar('Quick Action', 'You tapped $action');
  }

  void onPendingApprovalsTap() {
    Get.toNamed(AppRoutes.ADMIN_APPROVALS);
  }

  void goToAttendance() {
    Get.toNamed(AppRoutes.ADMIN_ATTENDANCE);
  }

  void goToFeeSnapshot() {
    Get.toNamed(AppRoutes.ADMIN_FEE_SNAPSHOT);
  }
}
