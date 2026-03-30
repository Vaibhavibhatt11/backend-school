import 'package:get/get.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';

class ClassAttendance {
  final String grade;
  final String teacher;
  final int percent;
  final int? absent;
  final bool perfect;
  final bool notSubmitted;
  ClassAttendance({
    required this.grade,
    required this.teacher,
    required this.percent,
    this.absent,
    this.perfect = false,
    this.notSubmitted = false,
  });
}

class AdminAttendanceController extends GetxController {
  AdminAttendanceController(this._adminService);

  final AdminService _adminService;
  final isLoading = false.obs;
  final studentPercent = 0.obs;
  final studentPresent = 0.obs;
  final studentTotal = 0.obs;
  final staffPercent = 0.obs;
  final staffPresent = 0.obs;
  final staffTotal = 0.obs;

  final classes = <ClassAttendance>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    isLoading.value = true;
    try {
      final overview = await _adminService.getAttendanceOverview();
      final student = overview['students'] as Map<String, dynamic>? ?? const {};
      final staff = overview['staff'] as Map<String, dynamic>? ?? const {};

      final studentSummary = student['summary'] as Map<String, dynamic>? ?? const {};
      final staffSummary = staff['summary'] as Map<String, dynamic>? ?? const {};
      final studentPresentCount = (studentSummary['PRESENT'] as num?)?.toInt() ?? 0;
      final studentLateCount = (studentSummary['LATE'] as num?)?.toInt() ?? 0;
      studentPresent.value = studentPresentCount + studentLateCount;
      studentTotal.value = (student['total'] as num?)?.toInt() ?? 0;
      final staffPresentCount = (staffSummary['PRESENT'] as num?)?.toInt() ?? 0;
      final staffLateCount = (staffSummary['LATE'] as num?)?.toInt() ?? 0;
      staffPresent.value = staffPresentCount + staffLateCount;
      staffTotal.value = (staff['total'] as num?)?.toInt() ?? 0;

      studentPercent.value = studentTotal.value > 0
          ? ((studentPresent.value / studentTotal.value) * 100).round()
          : 0;
      staffPercent.value = staffTotal.value > 0
          ? ((staffPresent.value / staffTotal.value) * 100).round()
          : 0;

      final trend = await _adminService.getAttendanceTrend(days: 7, type: 'student');
      final rows =
          (trend['days'] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>();
      final mapped = <ClassAttendance>[];
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final percent = ((row['presentPct'] as num?)?.toDouble() ?? 0).round();
        mapped.add(
          ClassAttendance(
            grade: row['date']?.toString().substring(5, 10) ?? 'Day ${i + 1}',
            teacher: 'Attendance',
            percent: percent,
            absent: (row['summary'] as Map<String, dynamic>?)?['ABSENT'] as int?,
            perfect: percent >= 99,
          ),
        );
      }
      classes.assignAll(mapped);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void onViewAll() {
    loadAttendance();
  }

  void onRemind(ClassAttendance cls) {
    loadAttendance();
  }

  void onMarkManual() {
    loadAttendance();
  }

  void onExportPDF() {
    loadAttendance();
  }
}
