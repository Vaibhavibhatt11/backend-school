import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
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
  bool _isNavigating = false;

  Future<void> _safeToNamed(String route, {dynamic arguments}) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      await Get.toNamed(route, arguments: arguments);
    } finally {
      _isNavigating = false;
    }
  }

  void onQuickActionTap(String action) {
    if (action == 'New Admission') {
      _safeToNamed(
        AppRoutes.ADMIN_MODULE_DETAIL,
        arguments: {'moduleId': 'admissions'},
      );
      return;
    }
    if (action == 'Broadcast') {
      _safeToNamed(
        AppRoutes.ADMIN_MODULE_DETAIL,
        arguments: {'moduleId': 'communication'},
      );
      return;
    }
    if (action == 'Mark Leave') {
      _safeToNamed(
        AppRoutes.ADMIN_MODULE_DETAIL,
        arguments: {'moduleId': 'attendance'},
      );
      return;
    }
    if (action == 'Collect Fee') {
      _safeToNamed(
        AppRoutes.ADMIN_MODULE_DETAIL,
        arguments: {'moduleId': 'fees'},
      );
      return;
    }
    AppToast.show('Module not mapped');
  }

  void onPendingApprovalsTap() {
    _safeToNamed(AppRoutes.ADMIN_APPROVALS, arguments: {'tabIndex': 1});
  }

  void goToAttendance() {
    _safeToNamed(AppRoutes.ADMIN_ATTENDANCE);
  }

  void goToFeeSnapshot() {
    _safeToNamed(AppRoutes.ADMIN_FEE_SNAPSHOT);
  }

  void goToAllModules() {
    _safeToNamed(AppRoutes.ADMIN_MODULES);
  }
}
