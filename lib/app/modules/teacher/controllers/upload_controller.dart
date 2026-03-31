import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_endpoints.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/utils/app_toast.dart';

class UploadController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final selectedClass = ''.obs;
  final selectedSubject = ''.obs;
  final uploadProgress = 0.0.obs;
  final isUploading = false.obs;
  final uploadHistory = <UploadHistoryItem>[].obs;

  final classes = <String>[].obs;
  final subjects = <String>[].obs;

  final Map<String, String> _classIdByLabel = {};
  final Map<String, String> _subjectIdByLabel = {};

  @override
  void onInit() {
    super.onInit();
    ever<String>(selectedClass, (_) => loadHistory());
    ever<String>(selectedSubject, (_) => loadHistory());
    _loadDropdownsAndHistory();
  }

  Future<void> _loadDropdownsAndHistory() async {
    await _loadClasses();
    await _loadSubjects();
    if (classes.isNotEmpty && selectedClass.value.isEmpty) selectedClass.value = classes.first;
    if (subjects.isNotEmpty && selectedSubject.value.isEmpty) selectedSubject.value = subjects.first;
    await loadHistory();
  }

  Future<void> _loadClasses() async {
    classes.clear();
    _classIdByLabel.clear();
    try {
      final res = await _apiClient.get(
        ApiEndpoints.schoolClasses,
        query: {'page': 1, 'limit': 200},
      );
      final payload = extractApiData(res.data, context: 'classes');
      final items = payload['items'];
      if (items is! List) return;

      for (final raw in items.whereType<Map>()) {
        final id = raw['id']?.toString();
        final name = raw['name']?.toString();
        final section = raw['section']?.toString() ?? '';
        if (id == null || id.isEmpty || name == null || name.isEmpty) continue;
        final label = section.isNotEmpty ? '${name}-$section' : name;
        _classIdByLabel[label] = id;
        classes.add(label);
      }
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> _loadSubjects() async {
    subjects.clear();
    _subjectIdByLabel.clear();
    try {
      final res = await _apiClient.get(
        ApiEndpoints.schoolSubjects,
        query: {'page': 1, 'limit': 200},
      );
      final payload = extractApiData(res.data, context: 'subjects');
      final items = payload['items'];
      if (items is! List) return;

      for (final raw in items.whereType<Map>()) {
        final id = raw['id']?.toString();
        final name = raw['name']?.toString();
        if (id == null || id.isEmpty || name == null || name.isEmpty) continue;
        _subjectIdByLabel[name] = id;
        subjects.add(name);
      }
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> loadHistory() async {
    if (selectedClass.value.isEmpty && selectedSubject.value.isEmpty) return;

    uploadHistory.clear();
    try {
      final classId = _classIdByLabel[selectedClass.value];
      final subjectId = _subjectIdByLabel[selectedSubject.value];

      final query = <String, dynamic>{
        'page': 1,
        'limit': 20,
        if (classId != null) 'classId': classId,
        if (subjectId != null) 'subjectId': subjectId,
      };

      final res = await _apiClient.get(
        ApiEndpoints.schoolStudyMaterials,
        query: query,
      );
      final payload = extractApiData(res.data, context: 'study materials');
      final items = payload['items'];
      if (items is! List) return;

      // Build reverse lookup only for display.
      final classLabelById = _classIdByLabel.map((k, v) => MapEntry(v, k));

      uploadHistory.assignAll(
        items.whereType<Map>().map((raw) {
          final id = raw['id']?.toString() ?? '';
          final title = raw['title']?.toString() ?? '';
          final type = raw['type']?.toString() ?? 'PDF';
          final url = raw['url']?.toString();
          final createdAtRaw = raw['createdAt']?.toString();
          final createdAt = createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null;
          final classId = raw['classId']?.toString();
          final targetClass = classId != null ? (classLabelById[classId] ?? classId) : (selectedClass.value.isNotEmpty ? selectedClass.value : '');
          return UploadHistoryItem(
            id: id,
            fileName: title,
            fileType: type,
            targetClass: targetClass,
            uploadedAt: createdAt ?? DateTime.now(),
            isShared: raw['isPublished'] == true,
          );
        }).toList(),
      );
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  void pickFile() {
    // Real file upload (multipart/url creation) is not implemented in this screen.
    AppToast.show('File upload is not wired yet. Study materials list is real.');
  }
}
