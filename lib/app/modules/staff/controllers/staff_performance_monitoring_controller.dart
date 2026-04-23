import 'package:erp_frontend/common/services/staff/staff_portal_store_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffPerformanceMonitoringController extends GetxController {
  StaffPerformanceMonitoringController(this._store);

  final StaffPortalStoreService _store;
  final Set<String> _resolvedWeakStudentNames = <String>{};

  final activeTab = 0.obs;
  final marks = <Map<String, String>>[].obs;
  final attendance = <Map<String, String>>[].obs;
  final progressReports = <Map<String, String>>[].obs;
  final weakStudents = <Map<String, String>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'attendance') activeTab.value = 1;
    if (args is Map && args['tab'] == 'reports') activeTab.value = 2;
    if (args is Map && args['tab'] == 'weak') activeTab.value = 3;
  }

  void setTab(int index) {
    if (index < 0 || index > 3) return;
    activeTab.value = index;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      marks.assignAll(await _loadCollection('marks'));
      attendance.assignAll(await _loadCollection('attendance'));
      progressReports.assignAll(await _loadCollection('progressReports'));
      final resolved = await _loadCollection('resolvedWeakStudents');
      _resolvedWeakStudentNames
        ..clear()
        ..addAll(
          resolved
              .map((row) => row['studentName'] ?? '')
              .where((name) => name.trim().isNotEmpty),
        );
      weakStudents.assignAll(await _loadCollection('weakStudents'));
      if (weakStudents.isEmpty) {
        await _rebuildWeakStudents();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMarks({
    required String studentName,
    required String subject,
    required String score,
  }) async {
    if (studentName.trim().isEmpty || subject.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'performanceMonitoring',
      collectionKey: 'marks',
      payload: {
        'studentName': studentName.trim(),
        'subject': subject.trim(),
        'score': score.trim().isEmpty ? '0' : score.trim(),
      },
    );
    await loadData();
    AppToast.show('Student marks tracked');
  }

  Future<void> addAttendance({
    required String studentName,
    required String percentage,
  }) async {
    if (studentName.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'performanceMonitoring',
      collectionKey: 'attendance',
      payload: {
        'studentName': studentName.trim(),
        'percentage': percentage.trim().isEmpty ? '0' : percentage.trim(),
      },
    );
    await loadData();
    AppToast.show('Attendance monitored');
  }

  Future<void> addProgressReport({
    required String studentName,
    required String summary,
    required String term,
  }) async {
    if (studentName.trim().isEmpty || summary.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'performanceMonitoring',
      collectionKey: 'progressReports',
      payload: {
        'studentName': studentName.trim(),
        'summary': summary.trim(),
        'term': term.trim().isEmpty ? 'Term 1' : term.trim(),
      },
    );
    await loadData();
    AppToast.show('Progress report added');
  }

  Future<void> resolveWeakStudent(String id) async {
    if (id.trim().isEmpty) return;
    final target = weakStudents.firstWhereOrNull((row) => row['id'] == id);
    final studentName = target?['studentName'] ?? '';
    if (studentName.trim().isNotEmpty) {
      _resolvedWeakStudentNames.add(studentName.trim());
      await _store.upsertCollectionItem(
        moduleKey: 'performanceMonitoring',
        collectionKey: 'resolvedWeakStudents',
        id: studentName.trim().toLowerCase(),
        payload: {
          'studentName': studentName.trim(),
        },
      );
    }
    await _store.deleteCollectionItem(
      moduleKey: 'performanceMonitoring',
      collectionKey: 'weakStudents',
      id: id,
    );
    await loadData();
    AppToast.show('Weak student marked for follow-up');
  }

  Map<String, int> metrics() {
    return {
      'marks': marks.length,
      'attendance': attendance.length,
      'reports': progressReports.length,
      'weak': weakStudents.length,
    };
  }

  Future<List<Map<String, String>>> _loadCollection(String key) async {
    final rows = await _store.readCollection('performanceMonitoring', key);
    return rows.map((row) {
      return row.map(
        (entryKey, value) => MapEntry(entryKey, value?.toString() ?? ''),
      );
    }).toList(growable: false);
  }

  Future<void> _rebuildWeakStudents() async {
    final weak = <Map<String, String>>[];
    for (final record in marks) {
      final score = int.tryParse(record['score'] ?? '0') ?? 0;
      final studentName = record['studentName'] ?? 'Student';
      if (_resolvedWeakStudentNames.contains(studentName.trim())) {
        continue;
      }
      if (score < 50) {
        weak.add({
          'id': record['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'studentName': studentName,
          'reason': 'Low marks (${record['score'] ?? '0'})',
        });
      }
    }
    for (final record in attendance) {
      final percentage = int.tryParse(record['percentage'] ?? '0') ?? 0;
      final studentName = record['studentName'] ?? 'Student';
      if (_resolvedWeakStudentNames.contains(studentName.trim())) {
        continue;
      }
      if (percentage < 75 &&
          weak.every((item) => item['studentName'] != studentName)) {
        weak.add({
          'id': record['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'studentName': studentName,
          'reason': 'Low attendance (${record['percentage'] ?? '0'}%)',
        });
      }
    }
    weakStudents.assignAll(weak);
    await _store.saveCollection(
      'performanceMonitoring',
      'weakStudents',
      weak.map((row) => <String, dynamic>{...row}).toList(growable: false),
    );
  }
}
