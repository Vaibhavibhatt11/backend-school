import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

enum AttendanceAudience { student, teacher }

class ClassAttendance {
  ClassAttendance({
    required this.grade,
    required this.teacher,
    required this.percent,
    this.absent,
    this.perfect = false,
    this.notSubmitted = false,
  });

  final String grade;
  final String teacher;
  final int percent;
  final int? absent;
  final bool perfect;
  final bool notSubmitted;
}

class AttendanceRecordItem {
  AttendanceRecordItem({
    required this.id,
    required this.name,
    required this.label,
    required this.status,
    this.inTime,
    this.outTime,
    this.remark,
  });

  final String id;
  final String name;
  final String label;
  final String status;
  final String? inTime;
  final String? outTime;
  final String? remark;
}

class BulkAttendanceTarget {
  BulkAttendanceTarget({
    required this.id,
    required this.name,
    required this.label,
    required this.status,
  });

  final String id;
  final String name;
  final String label;
  final RxString status;
}

class AttendanceTrendRow {
  AttendanceTrendRow({
    required this.dayLabel,
    required this.presentPct,
    required this.absentCount,
  });

  final String dayLabel;
  final int presentPct;
  final int absentCount;
}

class AdminAttendanceController extends GetxController {
  AdminAttendanceController(this._adminService);

  final AdminService _adminService;

  final isLoading = false.obs;
  final isSubmittingBulk = false.obs;
  final isSyncingIntegration = false.obs;

  final selectedDateIso = ''.obs;
  final selectedClassFilter = 'All Classes'.obs;
  final selectedSectionFilter = ''.obs;
  final selectedBulkAudience = AttendanceAudience.student.obs;
  final selectedBulkClass = 'All Classes'.obs;
  final selectedBulkSection = ''.obs;

  final classOptions = <String>['All Classes'].obs;
  final studentRecords = <AttendanceRecordItem>[].obs;
  final teacherRecords = <AttendanceRecordItem>[].obs;
  final trendRows = <AttendanceTrendRow>[].obs;
  final bulkTargets = <BulkAttendanceTarget>[].obs;

  final studentPercent = 0.obs;
  final studentPresent = 0.obs;
  final studentTotal = 0.obs;
  final teacherPercent = 0.obs;
  final teacherPresent = 0.obs;
  final teacherTotal = 0.obs;
  final classes = <ClassAttendance>[].obs;

  final biometricEnabled = false.obs;
  final faceEnabled = false.obs;
  final lastIntegrationSync = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedDateIso.value = _todayIsoDate();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadClassOptions(),
        _loadOverview(),
        _loadRecords(),
        _loadBulkTargets(),
        _loadIntegrationState(),
      ]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Backward-compatible entrypoint used by existing admin widgets.
  Future<void> loadAttendance() async {
    await loadInitialData();
  }

  Future<void> refreshRecords() async {
    try {
      await _loadRecords();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> refreshBulkTargets() async {
    try {
      await _loadBulkTargets();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> pickDate(DateTime date) async {
    selectedDateIso.value = _isoDate(date);
    await Future.wait([
      _loadOverview(),
      _loadRecords(),
      _loadBulkTargets(),
    ]);
  }

  Future<void> selectClassFilter(String value) async {
    selectedClassFilter.value = value;
    await _loadRecords();
  }

  Future<void> selectBulkClass(String value) async {
    selectedBulkClass.value = value;
    await _loadBulkTargets();
  }

  Future<void> setBulkAudience(AttendanceAudience audience) async {
    selectedBulkAudience.value = audience;
    await _loadBulkTargets();
  }

  void setBulkStatus(BulkAttendanceTarget target, String status) {
    target.status.value = status;
  }

  void markAllBulkTargets(String status) {
    for (final target in bulkTargets) {
      target.status.value = status;
    }
  }

  Future<void> submitBulkAttendance() async {
    if (bulkTargets.isEmpty) {
      AppToast.show('No records available for bulk marking.');
      return;
    }
    final pending = bulkTargets.where((item) => item.status.value.isEmpty).length;
    if (pending > 0) {
      AppToast.show('Please set attendance status for all entries.');
      return;
    }

    isSubmittingBulk.value = true;
    try {
      final isStudent = selectedBulkAudience.value == AttendanceAudience.student;
      final records = bulkTargets
          .map(
            (item) => {
              isStudent ? 'studentId' : 'staffId': item.id,
              'status': _uiStatusToBackend(item.status.value),
              'remark': null,
            },
          )
          .toList();
      await _adminService.markAttendanceBulk(
        type: isStudent ? 'student' : 'staff',
        date: selectedDateIso.value,
        records: records,
      );
      AppToast.show('Bulk attendance submitted successfully.');
      await Future.wait([_loadOverview(), _loadRecords(), _loadBulkTargets()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isSubmittingBulk.value = false;
    }
  }

  Future<void> openAttendanceReports() async {
    await Get.toNamed('/admin-reports');
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    biometricEnabled.value = enabled;
    await _syncIntegrationSettings();
  }

  Future<void> setFaceEnabled(bool enabled) async {
    faceEnabled.value = enabled;
    await _syncIntegrationSettings();
  }

  Future<void> syncIntegrationsNow() async {
    await _syncIntegrationSettings(forceSync: true);
  }

  Future<void> _loadClassOptions() async {
    final data = await _adminService.getClasses(page: 1, limit: 100);
    final options = <String>['All Classes'];
    final items = data['items'];
    if (items is List) {
      for (final row in items.whereType<Map>()) {
        final name = (row['name'] ?? '').toString().trim();
        final section = (row['section'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        final value = section.isEmpty ? name : '$name - $section';
        if (!options.contains(value)) options.add(value);
      }
    }
    classOptions.assignAll(options);
    if (!classOptions.contains(selectedClassFilter.value)) {
      selectedClassFilter.value = classOptions.first;
    }
    if (!classOptions.contains(selectedBulkClass.value)) {
      selectedBulkClass.value = classOptions.first;
    }
  }

  Future<void> _loadOverview() async {
    final overview = await _adminService.getAttendanceOverview(date: selectedDateIso.value);
    final student = overview['students'] as Map<String, dynamic>? ?? const {};
    final staff = overview['staff'] as Map<String, dynamic>? ?? const {};

    final studentSummary = student['summary'] as Map<String, dynamic>? ?? const {};
    final staffSummary = staff['summary'] as Map<String, dynamic>? ?? const {};

    final sPresent = (studentSummary['PRESENT'] as num?)?.toInt() ?? 0;
    final sLate = (studentSummary['LATE'] as num?)?.toInt() ?? 0;
    studentPresent.value = sPresent + sLate;
    studentTotal.value = (student['total'] as num?)?.toInt() ?? 0;
    studentPercent.value = studentTotal.value > 0
        ? ((studentPresent.value / studentTotal.value) * 100).round()
        : 0;

    final tPresent = (staffSummary['PRESENT'] as num?)?.toInt() ?? 0;
    final tLate = (staffSummary['LATE'] as num?)?.toInt() ?? 0;
    teacherPresent.value = tPresent + tLate;
    teacherTotal.value = (staff['total'] as num?)?.toInt() ?? 0;
    teacherPercent.value = teacherTotal.value > 0
        ? ((teacherPresent.value / teacherTotal.value) * 100).round()
        : 0;

    final trend = await _adminService.getAttendanceTrend(days: 7, type: 'student');
    final days = (trend['days'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((row) {
      final m = Map<String, dynamic>.from(row);
      final dayLabel = (m['date'] ?? '').toString();
      final pct = ((m['presentPct'] as num?)?.toDouble() ?? 0).round();
      final absent = ((m['summary'] as Map?)?['ABSENT'] as num?)?.toInt() ?? 0;
      return AttendanceTrendRow(
        dayLabel: dayLabel.length >= 10 ? dayLabel.substring(5, 10) : dayLabel,
        presentPct: pct,
        absentCount: absent,
      );
    }).toList();
    trendRows.assignAll(days);
    classes.assignAll(
      days
          .map(
            (row) => ClassAttendance(
              grade: row.dayLabel,
              teacher: 'Attendance',
              percent: row.presentPct,
              absent: row.absentCount,
              perfect: row.presentPct >= 99,
            ),
          )
          .toList(),
    );
  }

  Future<void> _loadRecords() async {
    final filters = _splitClassFilter(selectedClassFilter.value);
    final studentData = await _adminService.getAttendanceRecords(
      type: 'student',
      date: selectedDateIso.value,
      className: filters.className,
      section: filters.section,
      limit: 500,
    );
    final teacherData = await _adminService.getAttendanceRecords(
      type: 'staff',
      date: selectedDateIso.value,
      limit: 500,
    );
    studentRecords.assignAll(_mapRecords(studentData, isStudent: true));
    teacherRecords.assignAll(_mapRecords(teacherData, isStudent: false));
  }

  Future<void> _loadBulkTargets() async {
    final isStudent = selectedBulkAudience.value == AttendanceAudience.student;
    if (isStudent) {
      final filters = _splitClassFilter(selectedBulkClass.value);
      final students = await _adminService.getStudents(
        page: 1,
        limit: 300,
        className: filters.className,
        section: filters.section,
      );
      final records = await _adminService.getAttendanceRecords(
        type: 'student',
        date: selectedDateIso.value,
        className: filters.className,
        section: filters.section,
        limit: 1000,
      );
      final existing = _existingStatusByEntity(records, key: 'student');
      final items = (students['items'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      bulkTargets.assignAll(
        items.map((row) {
          final id = (row['id'] ?? '').toString();
          final name = _fullName(row['firstName'], row['lastName']);
          final roll = (row['rollNo'] ?? '').toString();
          return BulkAttendanceTarget(
            id: id,
            name: name.isEmpty ? 'Student' : name,
            label: roll.isEmpty ? 'Student' : 'Roll $roll',
            status: (existing[id] ?? '').obs,
          );
        }),
      );
      return;
    }

    final staff = await _adminService.getStaff(page: 1, limit: 300, isActive: true);
    final records = await _adminService.getAttendanceRecords(
      type: 'staff',
      date: selectedDateIso.value,
      limit: 1000,
    );
    final existing = _existingStatusByEntity(records, key: 'staff');
    final items = (staff['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    bulkTargets.assignAll(
      items.map((row) {
        final id = (row['id'] ?? '').toString();
        final fullName = (row['fullName'] ?? '').toString().trim();
        final code = (row['employeeCode'] ?? '').toString().trim();
        final designation = (row['designation'] ?? '').toString().trim();
        return BulkAttendanceTarget(
          id: id,
          name: fullName.isEmpty ? 'Teacher' : fullName,
          label: [code, designation].where((e) => e.isNotEmpty).join(' • '),
          status: (existing[id] ?? '').obs,
        );
      }),
    );
  }

  Future<void> _loadIntegrationState() async {
    final settings = await _adminService.getSchoolSettings();
    final attendance = settings['attendanceIntegration'];
    if (attendance is Map) {
      biometricEnabled.value = attendance['biometricEnabled'] == true;
      faceEnabled.value = attendance['faceEnabled'] == true;
      lastIntegrationSync.value = (attendance['lastSyncAt'] ?? '').toString();
    }
  }

  Future<void> _syncIntegrationSettings({bool forceSync = false}) async {
    isSyncingIntegration.value = true;
    try {
      final now = DateTime.now().toIso8601String();
      await _adminService.patchSchoolSettings({
        'attendanceIntegration': {
          'biometricEnabled': biometricEnabled.value,
          'faceEnabled': faceEnabled.value,
          if (forceSync) 'lastSyncAt': now,
        },
      });
      if (forceSync) {
        lastIntegrationSync.value = now;
        AppToast.show('Integration sync completed.');
      } else {
        AppToast.show('Integration settings updated.');
      }
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isSyncingIntegration.value = false;
    }
  }

  List<AttendanceRecordItem> _mapRecords(
    Map<String, dynamic> payload, {
    required bool isStudent,
  }) {
    final items = (payload['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row));
    return items.map((row) {
      final person = (row[isStudent ? 'student' : 'staff'] as Map?) ?? const {};
      final personMap = Map<String, dynamic>.from(person);
      final id = (personMap['id'] ?? '').toString();
      final name = isStudent
          ? _fullName(personMap['firstName'], personMap['lastName'])
          : (personMap['fullName'] ?? '').toString();
      final label = isStudent
          ? [
              (row['className'] ?? '').toString(),
              (row['section'] ?? '').toString(),
            ].where((e) => e.isNotEmpty).join(' - ')
          : (personMap['employeeCode'] ?? '').toString();
      return AttendanceRecordItem(
        id: id,
        name: name.isEmpty ? (isStudent ? 'Student' : 'Teacher') : name,
        label: label,
        status: _backendStatusToUi((row['status'] ?? '').toString()),
        inTime: (row['inTime'] ?? row['checkInTime'])?.toString(),
        outTime: (row['outTime'] ?? row['checkOutTime'])?.toString(),
        remark: (row['remark'] ?? '').toString(),
      );
    }).toList();
  }

  Map<String, String> _existingStatusByEntity(
    Map<String, dynamic> payload, {
    required String key,
  }) {
    final map = <String, String>{};
    final items = (payload['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row));
    for (final row in items) {
      final entity = row[key] as Map?;
      if (entity == null) continue;
      final id = (entity['id'] ?? '').toString();
      if (id.isEmpty) continue;
      map[id] = _backendStatusToUi((row['status'] ?? '').toString());
    }
    return map;
  }

  ({String? className, String? section}) _splitClassFilter(String raw) {
    if (raw.trim().isEmpty || raw == 'All Classes') {
      return (className: null, section: null);
    }
    final parts = raw.split(' - ');
    if (parts.length >= 2) {
      return (className: parts.first.trim(), section: parts[1].trim());
    }
    return (className: raw.trim(), section: null);
  }

  String _fullName(dynamic first, dynamic last) {
    final f = (first ?? '').toString().trim();
    final l = (last ?? '').toString().trim();
    return [f, l].where((p) => p.isNotEmpty).join(' ').trim();
  }

  String _backendStatusToUi(String status) {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return 'P';
      case 'ABSENT':
        return 'A';
      case 'LATE':
        return 'L';
      case 'LEAVE':
        return 'LV';
      default:
        return '';
    }
  }

  String _uiStatusToBackend(String status) {
    switch (status.toUpperCase()) {
      case 'P':
        return 'PRESENT';
      case 'A':
        return 'ABSENT';
      case 'L':
        return 'LATE';
      case 'LV':
        return 'LEAVE';
      default:
        return 'ABSENT';
    }
  }

  String _isoDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  String _todayIsoDate() => _isoDate(DateTime.now());

  // Backward-compatible aliases used by existing dashboard/detail views.
  RxInt get staffPercent => teacherPercent;
  RxInt get staffPresent => teacherPresent;
  RxInt get staffTotal => teacherTotal;
}
