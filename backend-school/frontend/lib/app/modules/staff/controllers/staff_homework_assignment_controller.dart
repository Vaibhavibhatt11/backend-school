import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/staff/staff_portal_store_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffHomeworkAssignmentController extends GetxController {
  StaffHomeworkAssignmentController(this._adminService, this._store);

  final AdminService _adminService;
  final StaffPortalStoreService _store;

  final activeTab = 0.obs;
  final assignments = <Map<String, String>>[].obs;
  final deadlines = <Map<String, String>>[].obs;
  final submissions = <Map<String, String>>[].obs;
  final feedbackItems = <Map<String, String>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'deadlines') activeTab.value = 1;
    if (args is Map && args['tab'] == 'submissions') activeTab.value = 2;
    if (args is Map && args['tab'] == 'feedback') activeTab.value = 3;
  }

  void setTab(int index) {
    if (index < 0 || index > 3) return;
    activeTab.value = index;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final remoteAssignments = await _loadRemoteAssignments();
      final localAssignments = await _loadCollection('assignmentsLocal');
      assignments.assignAll(_mergeRows(remoteAssignments, localAssignments));

      final remoteDeadlines = remoteAssignments
          .where((row) => (row['dueDate'] ?? '').trim().isNotEmpty)
          .map((row) => <String, String>{
                'id': row['id'] ?? '',
                'assignmentTitle': row['title'] ?? '',
                'dueDate': row['dueDate'] ?? '',
                'dueTime': row['dueTime'] ?? '',
              })
          .toList(growable: false);
      deadlines.assignAll(
        _mergeRows(remoteDeadlines, await _loadCollection('deadlines')),
      );
      submissions.assignAll(await _loadCollection('submissions'));
      feedbackItems.assignAll(await _loadCollection('feedbackItems'));
    } catch (_) {
      assignments.assignAll(await _loadCollection('assignmentsLocal'));
      deadlines.assignAll(await _loadCollection('deadlines'));
      submissions.assignAll(await _loadCollection('submissions'));
      feedbackItems.assignAll(await _loadCollection('feedbackItems'));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAssignment({
    required String title,
    required String className,
    required String subject,
  }) async {
    if (title.trim().isEmpty || className.trim().isEmpty) return;
    final payload = <String, dynamic>{
      'title': title.trim(),
      'name': title.trim(),
      'className': className.trim(),
      'subject': subject.trim(),
      'subjectName': subject.trim(),
      'description': title.trim(),
      'status': 'ACTIVE',
      'dueDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    };
    try {
      await _adminService.createHomework(payload);
      await loadData();
      AppToast.show('Assignment created');
    } catch (_) {
      await _store.upsertCollectionItem(
        moduleKey: 'homeworkAssignment',
        collectionKey: 'assignmentsLocal',
        payload: {
          'title': title.trim(),
          'className': className.trim(),
          'subject': subject.trim().isEmpty ? 'General' : subject.trim(),
          'status': 'ACTIVE',
        },
      );
      await loadData();
      AppToast.show('Assignment saved in staff workspace');
    }
  }

  Future<void> setDeadline({
    required String assignmentTitle,
    required String dueDate,
    required String dueTime,
  }) async {
    if (assignmentTitle.trim().isEmpty || dueDate.trim().isEmpty) return;
    final match = assignments.firstWhereOrNull(
      (row) => (row['title'] ?? '').trim().toLowerCase() ==
          assignmentTitle.trim().toLowerCase(),
    );
    final backendId = match?['backendId'] ?? '';
    if (backendId.isNotEmpty) {
      try {
        await _adminService.updateHomework(
          id: backendId,
          payload: {
            'dueDate': dueDate.trim(),
            'dueTime': dueTime.trim().isEmpty ? '23:59' : dueTime.trim(),
          },
        );
      } catch (_) {
        // Persist the schedule even when the dedicated homework update
        // endpoint rejects the minimal payload from this lightweight UI.
      }
    }
    await _store.upsertCollectionItem(
      moduleKey: 'homeworkAssignment',
      collectionKey: 'deadlines',
      id: match?['id'],
      payload: {
        'assignmentTitle': assignmentTitle.trim(),
        'dueDate': dueDate.trim(),
        'dueTime': dueTime.trim().isEmpty ? '23:59' : dueTime.trim(),
      },
    );
    await loadData();
    AppToast.show('Deadline set');
  }

  Future<void> addSubmission({
    required String studentName,
    required String assignmentTitle,
    required String status,
  }) async {
    if (studentName.trim().isEmpty || assignmentTitle.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'homeworkAssignment',
      collectionKey: 'submissions',
      payload: {
        'studentName': studentName.trim(),
        'assignmentTitle': assignmentTitle.trim(),
        'status': status.trim(),
      },
    );
    await loadData();
    AppToast.show('Submission updated');
  }

  Future<void> addFeedback({
    required String studentName,
    required String assignmentTitle,
    required String feedback,
  }) async {
    if (studentName.trim().isEmpty || feedback.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'homeworkAssignment',
      collectionKey: 'feedbackItems',
      payload: {
        'studentName': studentName.trim(),
        'assignmentTitle': assignmentTitle.trim(),
        'feedback': feedback.trim(),
      },
    );
    await loadData();
    AppToast.show('Feedback shared');
  }

  Map<String, int> metrics() {
    final submitted = submissions.where((e) => e['status'] == 'SUBMITTED').length;
    return {
      'assignments': assignments.length,
      'deadlines': deadlines.length,
      'submissions': submissions.length,
      'submitted': submitted,
      'feedback': feedbackItems.length,
    };
  }

  Future<List<Map<String, String>>> _loadRemoteAssignments() async {
    final data = await _adminService.getHomework(page: 1, limit: 200);
    final rawItems = data['items'];
    if (rawItems is! List) {
      return const <Map<String, String>>[];
    }
    return rawItems.whereType<Map>().map((row) {
      final item = row.cast<String, dynamic>();
      final classMap = item['class'] as Map<String, dynamic>? ?? const {};
      final subjectMap = item['subject'] as Map<String, dynamic>? ?? const {};
      final className = _firstText([item['className'], classMap['name']]);
      final section = _firstText([item['section'], classMap['section']]);
      return <String, String>{
        'id': _firstText([item['id'], item['title']]),
        'backendId': _firstText([item['id']]),
        'title': _firstText([item['title'], item['name'], 'Homework']),
        'className': section.isEmpty ? className : '$className - $section',
        'subject': _firstText([
          item['subjectName'],
          subjectMap['name'],
          item['subject'],
          'General',
        ]),
        'status': _firstText([
          item['status'],
          item['isPublished'] == true ? 'ACTIVE' : 'DRAFT',
        ]),
        'dueDate': _firstText([
          item['dueDate'],
          item['deadline'],
        ]),
        'dueTime': _firstText([item['dueTime']]),
      };
    }).toList(growable: false);
  }

  Future<List<Map<String, String>>> _loadCollection(String key) async {
    final rows = await _store.readCollection('homeworkAssignment', key);
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
    return merged.values.toList(growable: false);
  }

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}
