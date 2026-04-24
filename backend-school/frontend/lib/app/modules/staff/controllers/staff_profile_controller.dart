import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_portal_store_service.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffProfileController extends GetxController {
  StaffProfileController(this._staffService, this._store);

  final StaffService _staffService;
  final StaffPortalStoreService _store;
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
      Map<String, dynamic> data = const {};
      try {
        data = await _staffService.getProfile();
      } catch (_) {}
      final backup = await _store.readModule('profile');

      name.value = _stringValue(data['name'], backup['name']);
      department.value = _stringValue(data['department'], backup['department']);
      qualification.value = _stringValue(
        data['qualification'],
        backup['qualification'],
      );
      experience.value = _stringValue(data['experience'], backup['experience']);
      contact.value = _stringValue(data['contact'], backup['contact']);
      email.value = _stringValue(data['email'], backup['email']);
      staffId.value = _stringValue(data['staffId'], backup['staffId']);

      final liveRows = _parseDocumentRows(data['documentRows']);
      final backupRows = _parseDocumentRows(backup['documentRows']);
      documentRows.assignAll(liveRows.isNotEmpty ? liveRows : backupRows);

      final liveDocs = _parseDocuments(data['documents']);
      final backupDocs = _parseDocuments(backup['documents']);
      documents.assignAll(
        liveDocs.isNotEmpty
            ? liveDocs
            : (documentRows.isNotEmpty
                  ? documentRows
                        .map((row) => row['name'] ?? '')
                        .where((item) => item.trim().isNotEmpty)
                        .toList()
                  : backupDocs),
      );
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
      var syncedPrimary = false;
      try {
        await _staffService.updateProfile(payload: payload);
        syncedPrimary = true;
      } catch (_) {}
      await _store.patchModule('profile', payload);
      _applyLocalProfile(payload);
      AppToast.show(
        syncedPrimary
            ? 'Profile updated successfully'
            : 'Profile saved in staff workspace',
      );
      return true;
    } catch (e) {
      final apiError = dioOrApiErrorMessage(e);
      AppToast.show(
        apiError.isEmpty
            ? 'Profile update failed.'
            : apiError,
      );
      return false;
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

  Future<void> upsertDocument({
    required String? documentId,
    required String name,
    required String type,
    required String url,
  }) async {
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
    await _store.patchModule('profile', _profileSnapshot());
    AppToast.show(index >= 0 ? 'Document updated' : 'Document added');
  }

  Future<void> deleteDocument(String id) async {
    documentRows.removeWhere((row) => row['id'] == id);
    documents.assignAll(documentRows.map((e) => e['name'] ?? '').whereType<String>());
    await _store.patchModule('profile', _profileSnapshot());
    AppToast.show('Document removed');
  }

  Map<String, dynamic> _profileSnapshot() {
    return {
      'name': name.value,
      'department': department.value,
      'qualification': qualification.value,
      'experience': experience.value,
      'contact': contact.value,
      'email': email.value,
      'staffId': staffId.value,
      'documents': documents.toList(),
      'documentRows': documentRows
          .map((row) => <String, dynamic>{...row})
          .toList(growable: false),
    };
  }

  List<Map<String, String>> _parseDocumentRows(dynamic value) {
    if (value is! List) {
      return const <Map<String, String>>[];
    }
    return value.whereType<Map>().map((row) {
      return <String, String>{
        'id': (row['id'] ?? '').toString(),
        'name': (row['name'] ?? '').toString(),
        'url': (row['url'] ?? '').toString(),
        'type': (row['type'] ?? '').toString(),
      };
    }).toList(growable: false);
  }

  List<String> _parseDocuments(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _stringValue(dynamic primary, dynamic backup) {
    final primaryText = primary?.toString().trim() ?? '';
    if (primaryText.isNotEmpty) {
      return primaryText;
    }
    return backup?.toString().trim() ?? '';
  }
}

