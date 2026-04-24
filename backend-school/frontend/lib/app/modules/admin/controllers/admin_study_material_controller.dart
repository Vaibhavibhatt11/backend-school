import 'package:erp_frontend/app/modules/admin/models/admin_study_material_models.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class AdminStudyMaterialController extends GetxController {
  AdminStudyMaterialController(this._adminService);

  final AdminService _adminService;

  final isLoading = false.obs;
  final isClassesLoading = false.obs;
  final isSubjectsLoading = false.obs;
  final isPublishing = false.obs;
  final isDeleting = false.obs;
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;

  final errorMessage = ''.obs;
  final classError = ''.obs;
  final subjectError = ''.obs;

  final materials = <AdminStudyMaterialRecord>[].obs;
  final classOptions = <AdminStudyMaterialClassOption>[].obs;
  final subjectOptions = <AdminStudyMaterialSubjectOption>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData({bool showErrors = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([
        loadClasses(showErrors: showErrors),
        loadSubjects(showErrors: showErrors),
        loadMaterials(showErrors: showErrors),
      ]);
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      if (showErrors) {
        AppToast.show(errorMessage.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadClasses({bool showErrors = false}) async {
    isClassesLoading.value = true;
    classError.value = '';
    try {
      final data = await _adminService.getClasses(page: 1, limit: 200);
      final rawItems = data['items'];
      final next = <AdminStudyMaterialClassOption>[];
      if (rawItems is List) {
        for (final raw in rawItems.whereType<Map>()) {
          final item = raw.cast<String, dynamic>();
          final id = item['id']?.toString() ?? '';
          final name = item['name']?.toString().trim() ?? '';
          if (id.isEmpty || name.isEmpty) continue;
          next.add(
            AdminStudyMaterialClassOption(
              id: id,
              name: name,
              section: item['section']?.toString().trim() ?? '',
            ),
          );
        }
      }
      classOptions.assignAll(next);
    } catch (e) {
      classError.value = dioOrApiErrorMessage(e);
      if (showErrors) {
        AppToast.show(classError.value);
      }
    } finally {
      isClassesLoading.value = false;
    }
  }

  Future<void> loadSubjects({bool showErrors = false}) async {
    isSubjectsLoading.value = true;
    subjectError.value = '';
    try {
      final data = await _adminService.getSubjects(page: 1, limit: 200);
      final rawItems = data['items'];
      final next = <AdminStudyMaterialSubjectOption>[];
      if (rawItems is List) {
        for (final raw in rawItems.whereType<Map>()) {
          final item = raw.cast<String, dynamic>();
          final id = item['id']?.toString() ?? '';
          final name = item['name']?.toString().trim() ?? '';
          if (id.isEmpty || name.isEmpty) continue;
          next.add(
            AdminStudyMaterialSubjectOption(
              id: id,
              name: name,
              code: item['code']?.toString().trim() ?? '',
            ),
          );
        }
      }
      subjectOptions.assignAll(next);
    } catch (e) {
      subjectError.value = dioOrApiErrorMessage(e);
      if (showErrors) {
        AppToast.show(subjectError.value);
      }
    } finally {
      isSubjectsLoading.value = false;
    }
  }

  Future<void> loadMaterials({bool showErrors = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _adminService.getStudyMaterials(page: 1, limit: 200);
      final rawItems = data['items'];
      final next = <AdminStudyMaterialRecord>[];
      if (rawItems is List) {
        for (final raw in rawItems.whereType<Map>()) {
          final item = raw.cast<String, dynamic>();
          final title = _firstNonEmptyString([item['title']]);
          if (title.isEmpty) continue;

          final subject = item['subject'] as Map<String, dynamic>? ?? const {};
          final classData = item['class'] as Map<String, dynamic>? ?? const {};
          final classId = _firstNonEmptyString([
            item['classId'],
            classData['id'],
          ]);
          final className = _firstNonEmptyString([
            classData['name'],
            item['className'],
          ]);
          final section = _firstNonEmptyString([
            classData['section'],
            item['section'],
          ]);
          final classLabel = section.isEmpty
              ? className
              : className.isEmpty
              ? ''
              : '$className - $section';

          next.add(
            AdminStudyMaterialRecord(
              id: _firstNonEmptyString([item['id'], title]),
              title: title,
              type: _firstNonEmptyString([item['type'], 'NOTE']),
              url: _firstNonEmptyString([
                item['url'],
                item['fileUrl'],
                item['videoUrl'],
                item['resourceUrl'],
              ]),
              classId: classId,
              classLabel: classLabel,
              subjectId: _firstNonEmptyString([
                item['subjectId'],
                subject['id'],
              ]),
              subjectName: _firstNonEmptyString([
                subject['name'],
                item['subjectName'],
              ]),
              createdAt: _parseDate(
                item['createdAt'] ?? item['updatedAt'] ?? item['publishedAt'],
              ),
              isPublished: item['isPublished'] != false,
              description: _firstNonEmptyString([
                item['description'],
                item['content'],
                item['summary'],
              ]),
            ),
          );
        }
      }
      next.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      materials.assignAll(next);
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      if (showErrors) {
        AppToast.show(errorMessage.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<AdminStudyMaterialRecord> materialsForCategory(
    AdminStudyMaterialCategory category, {
    String query = '',
    String classId = '',
    String subjectId = '',
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    return materials.where((item) {
      if (item.category != category) return false;
      if (classId.trim().isNotEmpty && item.classId != classId.trim()) {
        return false;
      }
      if (subjectId.trim().isNotEmpty && item.subjectId != subjectId.trim()) {
        return false;
      }
      if (trimmedQuery.isEmpty) return true;
      final haystack =
          '${item.title} ${item.subjectName} ${item.classLabel} ${item.type} ${item.description}'
              .toLowerCase();
      return haystack.contains(trimmedQuery);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<AdminStudyMaterialRecord> recentMaterials({int limit = 4}) {
    final items = materials.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.take(limit).toList();
  }

  int countForCategory(AdminStudyMaterialCategory category) {
    return materials.where((item) => item.category == category).length;
  }

  AdminStudyMaterialRecord? findMaterial(String id) {
    return materials.firstWhereOrNull((item) => item.id == id);
  }

  AdminStudyMaterialClassOption? findClassOption(String id) {
    return classOptions.firstWhereOrNull((item) => item.id == id);
  }

  AdminStudyMaterialSubjectOption? findSubjectOption(String id) {
    return subjectOptions.firstWhereOrNull((item) => item.id == id);
  }

  Future<bool> createMaterial({
    required AdminStudyMaterialCategory category,
    required String title,
    String? url,
    List<int>? fileBytes,
    String? fileName,
    String description = '',
    String classId = '',
    String subjectId = '',
  }) async {
    final trimmedTitle = title.trim();
    final normalizedUrl = url != null ? normalizeUrl(url) : '';
    final trimmedDescription = description.trim();

    if (trimmedTitle.isEmpty) {
      AppToast.show('${category.singularLabel} title is required.');
      return false;
    }

    if (fileBytes == null && normalizedUrl.isEmpty) {
      AppToast.show('Please provide a URL or upload a file.');
      return false;
    }

    if (normalizedUrl.isNotEmpty && !looksLikeHttpUrl(normalizedUrl)) {
      AppToast.show('Enter a valid http or https URL.');
      return false;
    }

    isPublishing.value = true;
    uploadProgress.value = 0.0;
    try {
      String finalUrl = normalizedUrl;

      if (fileBytes != null && fileName != null) {
        isUploading.value = true;
        // Step 1: Upload the file
        final uploadRes = await _adminService.uploadFile(
          path: '/school/admissions/upload-document', // Using a generic upload if available, or specific
          bytes: fileBytes,
          fileName: fileName,
          context: 'file upload',
          onSendProgress: (sent, total) {
            uploadProgress.value = sent / total;
          },
        );
        finalUrl = uploadRes['url']?.toString() ?? '';
        if (finalUrl.isEmpty) {
          AppToast.show('Upload failed: No URL returned from server.');
          return false;
        }
      }

      // Step 2: Create the material record
      await _adminService.uploadStudyMaterial({
        'title': trimmedTitle,
        'type': category.apiType,
        'url': finalUrl,
        'isPublished': true,
        if (trimmedDescription.isNotEmpty) 'description': trimmedDescription,
        if (classId.trim().isNotEmpty) 'classId': classId.trim(),
        if (subjectId.trim().isNotEmpty) 'subjectId': subjectId.trim(),
      });
      await loadMaterials(showErrors: false);
      AppToast.show('${category.singularLabel} published.');
      return true;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      return false;
    } finally {
      isPublishing.value = false;
      isUploading.value = false;
    }
  }

  Future<PlatformFile?> pickFile(AdminStudyMaterialCategory category) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: category == AdminStudyMaterialCategory.videos ? FileType.video : FileType.custom,
        allowedExtensions: category == AdminStudyMaterialCategory.pdfs ? ['pdf'] : 
                           category == AdminStudyMaterialCategory.notes ? ['pdf', 'doc', 'docx', 'txt'] : 
                           null,
      );
      return result?.files.first;
    } catch (e) {
      AppToast.show('Error picking file: $e');
      return null;
    }
  }

  Future<bool> deleteMaterial(AdminStudyMaterialRecord item) async {
    if (item.id.trim().isEmpty) return false;
    isDeleting.value = true;
    try {
      await _adminService.deleteStudyMaterial(item.id);
      materials.removeWhere((record) => record.id == item.id);
      AppToast.show('Material deleted.');
      return true;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  String normalizeUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    if (value.startsWith('www.')) return 'https://$value';
    return value;
  }

  bool looksLikeHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    final text = value.toString().trim();
    if (text.isEmpty) return DateTime.now();
    return DateTime.tryParse(text)?.toLocal() ?? DateTime.now();
  }
}
