import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/staff/staff_portal_store_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffLessonPlanningController extends GetxController {
  StaffLessonPlanningController(this._adminService, this._store);

  final AdminService _adminService;
  final StaffPortalStoreService _store;

  final activeTab = 0.obs;
  final lessonPlans = <Map<String, String>>[].obs;
  final topicSchedules = <Map<String, String>>[].obs;
  final lessonNotes = <Map<String, String>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'topics') activeTab.value = 1;
    if (args is Map && args['tab'] == 'notes') activeTab.value = 2;
  }

  void setTab(int index) {
    if (index < 0 || index > 2) return;
    activeTab.value = index;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final remotePlans = await _loadRemoteLessonPlans();
      final localPlans = await _loadStoredCollection('lessonPlansExtras');
      final localTopics = await _loadStoredCollection('topicSchedules');
      final localNotes = await _loadStoredCollection('lessonNotes');

      lessonPlans.assignAll(_mergeRows(remotePlans, localPlans));
      topicSchedules.assignAll(localTopics);
      lessonNotes.assignAll(localNotes);
    } catch (_) {
      lessonPlans.assignAll(await _loadStoredCollection('lessonPlansExtras'));
      topicSchedules.assignAll(await _loadStoredCollection('topicSchedules'));
      lessonNotes.assignAll(await _loadStoredCollection('lessonNotes'));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addLessonPlan({
    required String className,
    required String subject,
    required String objective,
  }) async {
    if (className.trim().isEmpty || subject.trim().isEmpty) return;

    final payload = <String, dynamic>{
      'title': '${subject.trim()} plan',
      'className': className.trim(),
      'subject': subject.trim(),
      'objective': objective.trim().isEmpty
          ? 'General lesson objective'
          : objective.trim(),
      'date': DateTime.now().toIso8601String().split('T').first,
    };

    try {
      await _adminService.createLessonPlan(payload);
      await loadData();
      AppToast.show('Lesson plan created');
    } catch (_) {
      await _store.upsertCollectionItem(
        moduleKey: 'lessonPlanning',
        collectionKey: 'lessonPlansExtras',
        payload: payload,
      );
      await loadData();
      AppToast.show('Lesson plan saved in staff workspace');
    }
  }

  Future<void> addTopicSchedule({
    required String className,
    required String topic,
    required String date,
    required String period,
  }) async {
    if (topic.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'lessonPlanning',
      collectionKey: 'topicSchedules',
      payload: {
        'className': className.trim().isEmpty ? 'General' : className.trim(),
        'topic': topic.trim(),
        'date': date.trim(),
        'period': period.trim(),
      },
    );
    await loadData();
    AppToast.show('Topic scheduled');
  }

  Future<void> addLessonNote({
    required String title,
    required String note,
    required String className,
  }) async {
    if (title.trim().isEmpty || note.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'lessonPlanning',
      collectionKey: 'lessonNotes',
      payload: {
        'title': title.trim(),
        'note': note.trim(),
        'className': className.trim().isEmpty ? 'General' : className.trim(),
      },
    );
    await loadData();
    AppToast.show('Lesson note added');
  }

  Map<String, int> metrics() {
    return {
      'plans': lessonPlans.length,
      'topics': topicSchedules.length,
      'notes': lessonNotes.length,
    };
  }

  Future<List<Map<String, String>>> _loadRemoteLessonPlans() async {
    final data = await _adminService.getLessonPlans();
    final rawItems = data['items'];
    if (rawItems is! List) {
      return const <Map<String, String>>[];
    }
    return rawItems.whereType<Map>().map((row) {
      final item = row.cast<String, dynamic>();
      final className = _firstText([
        item['className'],
        (item['class'] as Map?)?['name'],
      ]);
      final section = _firstText([
        item['section'],
        (item['class'] as Map?)?['section'],
      ]);
      final classLabel = section.isEmpty ? className : '$className - $section';
      return <String, String>{
        'id': _firstText([item['id'], item['title'], DateTime.now().millisecondsSinceEpoch]),
        'className': classLabel.isEmpty ? 'General' : classLabel,
        'subject': _subjectName(item),
        'objective': _firstText([
          item['objective'],
          item['description'],
          item['title'],
        ]),
      };
    }).toList(growable: false);
  }

  Future<List<Map<String, String>>> _loadStoredCollection(String key) async {
    final rows = await _store.readCollection('lessonPlanning', key);
    return rows.map(_stringMap).toList(growable: false);
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
    return merged.values.toList(growable: false);
  }

  String _subjectName(Map<String, dynamic> item) {
    final subject = item['subject'];
    if (subject is Map) {
      final name = subject['name']?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    }
    return _firstText([item['subjectName'], item['subject'], 'General']);
  }

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  Map<String, String> _stringMap(Map<String, dynamic> value) {
    return value.map(
      (key, data) => MapEntry(key, data?.toString() ?? ''),
    );
  }
}
