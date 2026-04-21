import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffProfileController extends GetxController {
  StaffProfileController(this._staffService);

  final StaffService _staffService;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  final name = ''.obs;
  final department = ''.obs;
  final qualification = ''.obs;
  final experience = ''.obs;
  final contact = ''.obs;
  final email = ''.obs;
  final documents = <String>[].obs;
  final documentRows = <Map<String, String>>[].obs;
  final staffId = ''.obs;
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getProfile();
      name.value = (data['name'] ?? '').toString();
      department.value = (data['department'] ?? '').toString();
      qualification.value = (data['qualification'] ?? '').toString();
      experience.value = (data['experience'] ?? '').toString();
      contact.value = (data['contact'] ?? '').toString();
      email.value = (data['email'] ?? '').toString();
      staffId.value = (data['staffId'] ?? '').toString();
      final rawDocs = data['documents'];
      if (rawDocs is List) {
        documents.assignAll(rawDocs.map((e) => e.toString()));
      } else {
        documents.clear();
      }
      documentRows.clear();
      final rows = data['documentRows'];
      if (rows is List) {
        for (final e in rows) {
          if (e is Map) {
            documentRows.add({
              'id': (e['id'] ?? '').toString(),
              'name': (e['name'] ?? '').toString(),
              'url': (e['url'] ?? '').toString(),
              'type': (e['type'] ?? '').toString(),
            });
          }
        }
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(int index) {
    if (index < 0 || index > 6) return;
    activeTab.value = index;
  }

  Future<bool> saveProfile({
    required String name,
    required String department,
    required String qualification,
    required String experience,
    required String contact,
    required String email,
  }) async {
    if (name.trim().isEmpty) {
      AppToast.show('Name is required');
      return false;
    }
    isSaving.value = true;
    final nextDocumentRows = documentRows
        .map((row) => <String, dynamic>{
              'id': row['id'] ?? '',
              'name': row['name'] ?? '',
              'url': row['url'] ?? '',
              'type': row['type'] ?? 'General',
            })
        .toList();
    final nextDocuments = nextDocumentRows
        .map((row) => (row['name'] ?? '').toString())
        .where((name) => name.trim().isNotEmpty)
        .toList();
    final payload = <String, dynamic>{
      'name': name.trim(),
      'department': department.trim(),
      'qualification': qualification.trim(),
      'experience': experience.trim(),
      'contact': contact.trim(),
      'email': email.trim(),
      'staffId': staffId.value.trim(),
      'documents': nextDocuments,
      'documentRows': nextDocumentRows,
    };
    try {
      await _staffService.updateProfile(payload: payload);
      _applyLocalProfile(payload);
      AppToast.show('Profile updated successfully');
      return true;
    } catch (e) {
      _applyLocalProfile(payload);
      final apiError = dioOrApiErrorMessage(e);
      AppToast.show(
        apiError.isEmpty
            ? 'Saved locally. Profile update API unavailable.'
            : '$apiError. Saved locally.',
      );
      return true;
    } finally {
      isSaving.value = false;
    }
  }

  void _applyLocalProfile(Map<String, dynamic> payload) {
    name.value = (payload['name'] ?? '').toString();
    department.value = (payload['department'] ?? '').toString();
    qualification.value = (payload['qualification'] ?? '').toString();
    experience.value = (payload['experience'] ?? '').toString();
    contact.value = (payload['contact'] ?? '').toString();
    email.value = (payload['email'] ?? '').toString();
  }

  void upsertDocument({
    required String? documentId,
    required String name,
    required String type,
    required String url,
  }) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      AppToast.show('Document name is required');
      return;
    }
    final nextId = (documentId == null || documentId.trim().isEmpty)
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : documentId;
    final entry = <String, String>{
      'id': nextId,
      'name': cleanName,
      'type': type.trim().isEmpty ? 'General' : type.trim(),
      'url': url.trim(),
    };
    final index = documentRows.indexWhere((row) => row['id'] == nextId);
    if (index >= 0) {
      documentRows[index] = entry;
    } else {
      documentRows.add(entry);
    }
    documents.assignAll(documentRows.map((e) => e['name'] ?? '').whereType<String>());
    AppToast.show(index >= 0 ? 'Document updated' : 'Document added');
  }

  void deleteDocument(String id) {
    documentRows.removeWhere((row) => row['id'] == id);
    documents.assignAll(documentRows.map((e) => e['name'] ?? '').whereType<String>());
    AppToast.show('Document removed');
  }
}

