import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:get/get.dart';
import 'admin_shell_controller.dart';

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
      final dashboardData = await _tryLoad(_adminService.getSchoolAdminDashboard());
      final profileData = await _tryLoad(_adminService.getProfileMe());
      final approvalsData = await _tryLoad(_adminService.getPendingApprovalsSummary());
      final feeSnapshotData = await _tryLoad(_adminService.getFeeSnapshot());
      final attendanceTrendData = await _tryLoad(_adminService.getAttendanceTrend(days: 7));
      final attendanceOverviewData = await _tryLoad(_adminService.getAttendanceOverview());

      final profile = profileData?['profile'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      adminName.value = profile['fullName']?.toString() ?? 'Admin';

      final ui = dashboardData?['ui'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final overview = attendanceOverviewData ?? const <String, dynamic>{};
      final feeSnapshot = feeSnapshotData ?? const <String, dynamic>{};
      final approvals = approvalsData ?? const <String, dynamic>{};

      totalStudents.value =
          _firstInt(
            [
              ui['studentsTotal'],
              dashboardData?['students'],
              overview['studentsTotal'],
              overview['totalStudents'],
            ],
          ) ??
          0;

      teacherPresent.value =
          _firstInt(
            [
              ui['teacherPresent'],
              overview['teacherPresent'],
              overview['presentTeachers'],
            ],
          ) ??
          0;
      teacherTotal.value =
          _firstInt(
            [
              ui['teacherTotal'],
              overview['teacherTotal'],
              overview['totalTeachers'],
            ],
          ) ??
          0;
      teacherPresence.value =
          _firstDouble(
            [
              ui['teacherPresence'],
              overview['teacherPresence'],
              if (teacherTotal.value > 0)
                (teacherPresent.value / teacherTotal.value) * 100,
            ],
          ) ??
          0;
      pendingApprovals.value =
          _firstInt(
            [
              ui['pendingApprovals'],
              approvals['totalPending'],
              (approvals['topItems'] as List?)?.length,
            ],
          ) ??
          0;
      feeToday.value =
          _firstDouble(
            [
              ui['feeToday'],
              feeSnapshot['todayCollected'],
              feeSnapshot['thisWeekCollected'],
            ],
          ) ??
          0;
      feePending.value =
          _firstDouble(
            [
              ui['feePending'],
              feeSnapshot['pendingAmount'],
            ],
          ) ??
          0;
      feeVsLastWeekPct.value =
          _firstDouble(
            [
              ui['feeVsLastWeekPct'],
              feeSnapshot['vsLastWeekPct'],
            ],
          ) ??
          0;

      final trendRows = _extractTrendRows(ui, attendanceTrendData);
      final trend = trendRows
          .map(
            (row) => _firstDouble(
                  [
                    row['presentPct'],
                    row['attendancePct'],
                    row['studentAttendancePct'],
                    row['value'],
                  ],
                ) ??
                0,
          )
          .toList();
      while (trend.length < 7) {
        trend.insert(0, 0);
      }
      attendanceTrend.assignAll(trend.take(7).toList());
      studentAttendancePct.value =
          _firstDouble(
            [
              ui['studentAttendancePct'],
              ui['studentAttendance'],
              overview['studentAttendancePct'],
              overview['attendancePct'],
              if (attendanceTrend.isNotEmpty) attendanceTrend.last,
            ],
          ) ??
          0;

      final hasAnyData =
          dashboardData != null ||
          approvalsData != null ||
          feeSnapshotData != null ||
          attendanceOverviewData != null ||
          attendanceTrendData != null;
      dashboardError.value = hasAnyData ? null : 'Dashboard unavailable.';
      if (!hasAnyData) {
        _resetDashboardKpis();
        AppToast.show('Dashboard unavailable.');
      }
    } catch (e) {
      dashboardError.value = dioOrApiErrorMessage(e);
      _resetDashboardKpis();
      AppToast.show(dashboardError.value ?? 'Dashboard unavailable.');
      adminName.value = 'Admin';
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

  Future<Map<String, dynamic>?> _tryLoad(
    Future<Map<String, dynamic>> request,
  ) async {
    try {
      return await request;
    } catch (_) {
      return null;
    }
  }

  int? _firstInt(List<dynamic> values) {
    for (final value in values) {
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  double? _firstDouble(List<dynamic> values) {
    for (final value in values) {
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  List<Map<String, dynamic>> _extractTrendRows(
    Map<String, dynamic> ui,
    Map<String, dynamic>? trendData,
  ) {
    final direct = ui['attendanceTrend'];
    if (direct is List) {
      return direct
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }
    final fallback = trendData?['trend'] ?? trendData?['items'] ?? trendData?['rows'];
    if (fallback is List) {
      return fallback
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  Future<void> _safeToNamed(String route, {dynamic arguments}) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      SafeNavigation.toNamed(route, arguments: arguments);
      await Future.delayed(const Duration(milliseconds: 250));
    } finally {
      _isNavigating = false;
    }
  }

  void _goToAdminTab(int index) {
    if (Get.isRegistered<AdminShellController>()) {
      Get.find<AdminShellController>().setTab(index);
      if (Get.currentRoute != AppRoutes.ADMIN_HOME) {
        _safeToNamed(AppRoutes.ADMIN_HOME, arguments: {'tabIndex': index});
      }
      return;
    }
    _safeToNamed(AppRoutes.ADMIN_HOME, arguments: {'tabIndex': index});
  }

  void onQuickActionTap(String action) {
    if (action == 'New Admission') {
      _goToAdminTab(1);
      return;
    }
    if (action == 'Broadcast') {
      _goToAdminTab(3);
      return;
    }
    if (action == 'Mark Leave') {
      _safeToNamed(AppRoutes.ADMIN_ATTENDANCE, arguments: {'tabIndex': 0});
      return;
    }
    if (action == 'Collect Fee') {
      _safeToNamed(AppRoutes.ADMIN_FEE_SNAPSHOT, arguments: {'tabIndex': 0});
      return;
    }
    _goToAdminTab(0);
  }

  void onPendingApprovalsTap() {
    _goToAdminTab(1);
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
