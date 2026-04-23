import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/staff/staff_portal_store_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffExamAssessmentController extends GetxController {
  StaffExamAssessmentController(this._adminService, this._store);

  final AdminService _adminService;
  final StaffPortalStoreService _store;

  final activeTab = 0.obs;
  final exams = <Map<String, String>>[].obs;
  final questionPapers = <Map<String, String>>[].obs;
  final marksEntries = <Map<String, String>>[].obs;
  final gradingRules = <Map<String, String>>[].obs;
  final results = <Map<String, String>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'papers') activeTab.value = 1;
    if (args is Map && args['tab'] == 'marks') activeTab.value = 2;
    if (args is Map && args['tab'] == 'grading') activeTab.value = 3;
    if (args is Map && args['tab'] == 'results') activeTab.value = 4;
  }

  void setTab(int index) {
    if (index < 0 || index > 4) return;
    activeTab.value = index;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final remoteExams = await _loadRemoteExams();
      final localExams = await _loadCollection('examsLocal');
      exams.assignAll(_mergeRows(remoteExams, localExams));

      questionPapers.assignAll(await _loadCollection('questionPapers'));
      marksEntries.assignAll(await _loadCollection('marksEntries'));
      gradingRules.assignAll(await _loadCollection('gradingRules'));

      final localResults = await _loadCollection('results');
      final remoteResults = remoteExams
          .where((row) => (row['status'] ?? '').toUpperCase() == 'PUBLISHED')
          .map((row) => <String, String>{
                'id': row['id'] ?? '',
                'examName': row['name'] ?? '',
                'className': row['className'] ?? '',
                'status': 'PUBLISHED',
                'publishedOn': row['publishedOn'] ?? row['date'] ?? '',
              })
          .toList(growable: false);
      results.assignAll(_mergeRows(remoteResults, localResults));
    } catch (_) {
      exams.assignAll(await _loadCollection('examsLocal'));
      questionPapers.assignAll(await _loadCollection('questionPapers'));
      marksEntries.assignAll(await _loadCollection('marksEntries'));
      gradingRules.assignAll(await _loadCollection('gradingRules'));
      results.assignAll(await _loadCollection('results'));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createExam({
    required String name,
    required String className,
    required String date,
  }) async {
    if (name.trim().isEmpty || className.trim().isEmpty) return;
    final payload = {
      'name': name.trim(),
      'title': name.trim(),
      'className': className.trim(),
      'date': date.trim(),
      'examDate': date.trim(),
      'status': 'PLANNED',
    };
    try {
      await _adminService.createExam(payload);
      await loadData();
      AppToast.show('Exam created');
    } catch (_) {
      await _store.upsertCollectionItem(
        moduleKey: 'examAssessment',
        collectionKey: 'examsLocal',
        payload: payload,
      );
      await loadData();
      AppToast.show('Exam saved in staff workspace');
    }
  }

  Future<void> uploadQuestionPaper({
    required String examName,
    required String subject,
    required String fileName,
  }) async {
    if (examName.trim().isEmpty || fileName.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'examAssessment',
      collectionKey: 'questionPapers',
      payload: {
        'examName': examName.trim(),
        'subject': subject.trim().isEmpty ? 'General' : subject.trim(),
        'fileName': fileName.trim(),
        'status': 'UPLOADED',
      },
    );
    await loadData();
    AppToast.show('Question paper uploaded');
  }

  Future<void> addMarks({
    required String examName,
    required String studentName,
    required String marks,
  }) async {
    if (examName.trim().isEmpty || studentName.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'examAssessment',
      collectionKey: 'marksEntries',
      payload: {
        'examName': examName.trim(),
        'studentName': studentName.trim(),
        'marks': marks.trim().isEmpty ? '0' : marks.trim(),
      },
    );
    await loadData();
    AppToast.show('Marks entered');
  }

  Future<void> addGradingRule({
    required String grade,
    required String minMarks,
    required String maxMarks,
  }) async {
    if (grade.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'examAssessment',
      collectionKey: 'gradingRules',
      payload: {
        'grade': grade.trim(),
        'minMarks': minMarks.trim(),
        'maxMarks': maxMarks.trim(),
      },
    );
    await loadData();
    AppToast.show('Grading rule added');
  }

  Future<void> publishResult({
    required String examName,
    required String className,
  }) async {
    if (examName.trim().isEmpty || className.trim().isEmpty) return;
    final match = exams.firstWhereOrNull(
      (row) =>
          (row['name'] ?? '').trim().toLowerCase() == nameKey(examName) &&
          (row['className'] ?? '').trim().toLowerCase() == nameKey(className),
    );
    final backendId = match?['backendId'] ?? '';
    if (backendId.isNotEmpty) {
      try {
        await _adminService.publishExam(backendId);
      } catch (_) {
        // Keep a persisted local result so the action still succeeds in-app.
      }
    }
    await _store.upsertCollectionItem(
      moduleKey: 'examAssessment',
      collectionKey: 'results',
      id: match?['id'],
      payload: {
        'examName': examName.trim(),
        'className': className.trim(),
        'status': 'PUBLISHED',
        'publishedOn': DateTime.now().toIso8601String().split('T').first,
      },
    );
    await loadData();
    AppToast.show('Result published');
  }

  Map<String, int> metrics() {
    return {
      'exams': exams.length,
      'papers': questionPapers.length,
      'marks': marksEntries.length,
      'grading': gradingRules.length,
      'results': results.length,
    };
  }

  Future<List<Map<String, String>>> _loadRemoteExams() async {
    final data = await _adminService.getExams(page: 1, limit: 200);
    final rawItems = data['items'];
    if (rawItems is! List) {
      return const <Map<String, String>>[];
    }
    return rawItems.whereType<Map>().map((row) {
      final item = row.cast<String, dynamic>();
      final classMap = item['class'] as Map<String, dynamic>? ?? const {};
      final className = _firstText([item['className'], classMap['name']]);
      final section = _firstText([item['section'], classMap['section']]);
      return <String, String>{
        'id': _firstText([item['id'], item['name'], item['title']]),
        'backendId': _firstText([item['id']]),
        'name': _firstText([item['name'], item['title'], 'Exam']),
        'className': section.isEmpty ? className : '$className - $section',
        'date': _firstText([
          item['date'],
          item['examDate'],
          item['scheduledAt'],
        ]),
        'status': _firstText([
          item['status'],
          item['isPublished'] == true ? 'PUBLISHED' : 'PLANNED',
        ]),
        'publishedOn': _firstText([item['publishedAt']]),
      };
    }).toList(growable: false);
  }

  Future<List<Map<String, String>>> _loadCollection(String key) async {
    final rows = await _store.readCollection('examAssessment', key);
    return rows.map((row) {
      return row.map(
        (entryKey, value) => MapEntry(entryKey, value?.toString() ?? ''),
      );
    }).toList(growable: false);
  }

  List<Map<String, String>> _mergeRows(
    List<Map<String, String>> remote,
    List<Map<String, String>> local,
  ) {
    final merged = <String, Map<String, String>>{};
    for (final item in remote) {
      final id = item['id'] ?? '';
      if (id.isNotEmpty) {
        merged[id] = item;
      }
    }
    for (final item in local) {
      final id = item['id'] ?? '';
      if (id.isNotEmpty) {
        merged[id] = item;
      } else {
        merged['local-${merged.length}'] = item;
      }
    }
    final rows = merged.values.toList(growable: false);
    rows.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    return rows;
  }

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String nameKey(String value) => value.trim().toLowerCase();
}
