import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  AdminDashboardController(this._adminService);

  final AdminService _adminService;

  final quickActions = [
    'New Admission',
    'Broadcast',
    'Mark Leave',
    'Collect Fee',
  ];

  final isLoading = false.obs;
  final adminName = 'Admin'.obs;
  final totalStudents = 0.obs;
  final teacherPresence = 0.0.obs;
  final teacherPresent = 0.obs;
  final teacherTotal = 0.obs;
  final pendingApprovals = 0.obs;
  final feeToday = 0.0.obs;
  final feePending = 0.0.obs;
  final feeVsLastWeekPct = 0.0.obs;
  final attendanceTrend = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  /// Student attendance % (today / overview), not teacher presence.
  final studentAttendancePct = 0.0.obs;
  bool _isNavigating = false;

  /// Set when `GET /dashboard/school-admin` fails — no stitched “fallback” KPIs.
  final dashboardError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    dashboardError.value = null;
    try {
      final data = await _adminService.getSchoolAdminDashboard();
      dashboardError.value = null;
      try {
        final profileData = await _adminService.getProfileMe();
        final profile = profileData['profile'] as Map<String, dynamic>? ?? const <String, dynamic>{};
        adminName.value = profile['fullName']?.toString() ?? 'Admin';
      } catch (_) {
        adminName.value = 'Admin';
      }

      final ui = data['ui'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      totalStudents.value =
          (ui['studentsTotal'] as num?)?.toInt() ??
          (data['students'] as num?)?.toInt() ??
          0;
      teacherPresence.value = (ui['teacherPresence'] as num?)?.toDouble() ?? 0;
      teacherPresent.value = (ui['teacherPresent'] as num?)?.toInt() ?? 0;
      teacherTotal.value = (ui['teacherTotal'] as num?)?.toInt() ?? 0;
      pendingApprovals.value = (ui['pendingApprovals'] as num?)?.toInt() ?? 0;
      feeToday.value = (ui['feeToday'] as num?)?.toDouble() ?? 0;
      feePending.value = (ui['feePending'] as num?)?.toDouble() ?? 0;
      feeVsLastWeekPct.value = (ui['feeVsLastWeekPct'] as num?)?.toDouble() ?? 0;

      final trendRows = (ui['attendanceTrend'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();
      final trend = trendRows
          .map((row) => (row['presentPct'] as num?)?.toDouble() ?? 0)
          .toList();
      while (trend.length < 7) {
        trend.insert(0, 0);
      }
      attendanceTrend.assignAll(trend.take(7).toList());
      studentAttendancePct.value =
          (ui['studentAttendancePct'] as num?)?.toDouble() ??
          (ui['studentAttendance'] as num?)?.toDouble() ??
          (attendanceTrend.isNotEmpty ? attendanceTrend.last : 0);
    } catch (e) {
      dashboardError.value = dioOrApiErrorMessage(e);
      _resetDashboardKpis();
      AppToast.show(dashboardError.value ?? 'Dashboard unavailable.');
      try {
        final profileData = await _adminService.getProfileMe();
        final profile = profileData['profile'] as Map<String, dynamic>? ?? const <String, dynamic>{};
        adminName.value = profile['fullName']?.toString() ?? 'Admin';
      } catch (_) {
        adminName.value = 'Admin';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _resetDashboardKpis() {
    attendanceTrend.assignAll(<double>[0, 0, 0, 0, 0, 0, 0]);
    studentAttendancePct.value = 0;
    totalStudents.value = 0;
    teacherPresence.value = 0;
    teacherPresent.value = 0;
    teacherTotal.value = 0;
    pendingApprovals.value = 0;
    feeToday.value = 0;
    feePending.value = 0;
    feeVsLastWeekPct.value = 0;
  }

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
      _safeToNamed(AppRoutes.ADMIN_APPROVALS, arguments: {'tabIndex': 1});
      return;
    }
    if (action == 'Broadcast') {
      _safeToNamed(AppRoutes.ADMIN_NOTICE_BOARD, arguments: {'tabIndex': 3});
      return;
    }
    if (action == 'Mark Leave') {
      _safeToNamed(AppRoutes.ADMIN_ATTENDANCE);
      return;
    }
    if (action == 'Collect Fee') {
      _safeToNamed(AppRoutes.ADMIN_FEE_SNAPSHOT);
      return;
    }
    _safeToNamed(AppRoutes.ADMIN_HOME);
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
    _safeToNamed(AppRoutes.ADMIN_HOME, arguments: {'tabIndex': 0});
  }
}
