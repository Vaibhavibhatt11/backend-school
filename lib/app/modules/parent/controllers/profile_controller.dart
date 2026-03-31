import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_profile_service.dart';

class ProfileController extends GetxController {
  final ParentProfileService _profileService = Get.find<ParentProfileService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = ''.obs;
  final studentClass = ''.obs;
  final studentPhotoUrl = ''.obs;
  final academicYear = ''.obs;
  final dob = ''.obs;
  final bloodGroup = ''.obs;
  final fatherName = ''.obs;
  final motherName = ''.obs;
  final currentTermGrade = ''.obs;
  final currentTermPercentage = 0.0.obs;
  final classAvg = 0.0.obs;
  final errorMessage = ''.obs;

  final documents = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadProfile(),
    );
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _profileService.getProfileHub(
        childId: _parentContext.selectedChildId.value,
      );
      studentName.value = data['studentName']?.toString() ?? studentName.value;
      studentClass.value = data['studentClass']?.toString() ?? studentClass.value;
      studentPhotoUrl.value =
          (data['photoUrl'] ?? data['avatarUrl'] ?? data['studentPhotoUrl'] ?? studentPhotoUrl.value)
              .toString();
      academicYear.value = data['academicYear']?.toString() ?? academicYear.value;
      dob.value = data['dob']?.toString() ?? dob.value;
      bloodGroup.value = data['bloodGroup']?.toString() ?? bloodGroup.value;
      fatherName.value = data['fatherName']?.toString() ?? fatherName.value;
      motherName.value = data['motherName']?.toString() ?? motherName.value;
      final termPercent = data['currentTermPercentage'];
      currentTermPercentage.value = termPercent is num ? termPercent.toDouble() : 0.0;
      final avg = data['classAvg'];
      classAvg.value = avg is num ? avg.toDouble() : 0.0;
      currentTermGrade.value = _gradeFromPercent(currentTermPercentage.value);
      final docs = data['documents'];
      if (docs is List) {
        documents.assignAll(docs.whereType<Map>().map((e) {
          final m = Map<String, dynamic>.from(e);
          final sizeKb = m['sizeKb'];
          final sizeLabel = sizeKb is num ? '${sizeKb.toStringAsFixed(0)} KB' : '-';
          return {
            ...m,
            'name': (m['name'] ?? 'Document').toString(),
            'status': (m['status'] ?? 'AVAILABLE').toString(),
            'size': sizeLabel,
          };
        }));
      } else {
        documents.clear();
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  String _gradeFromPercent(double percent) {
    if (percent >= 90) return 'A+';
    if (percent >= 80) return 'A';
    if (percent >= 70) return 'B';
    if (percent >= 60) return 'C';
    if (percent >= 50) return 'D';
    return 'E';
  }

  Future<void> editPersonal() async {
    final nameCtrl = TextEditingController(text: studentName.value);
    final dobCtrl = TextEditingController(text: dob.value);
    final bloodCtrl = TextEditingController(text: bloodGroup.value);
    final confirmed = await _showEditDialog(
      title: 'Edit Personal Details',
      fields: [
        _EditField('Student Name', nameCtrl),
        _EditField('Date of Birth (YYYY-MM-DD)', dobCtrl),
        _EditField('Blood Group', bloodCtrl),
      ],
    );
    if (!confirmed) return;
    await _saveProfileUpdates({
      'studentName': nameCtrl.text.trim(),
      'dob': dobCtrl.text.trim(),
      'bloodGroup': bloodCtrl.text.trim(),
    });
  }

  Future<void> editGuardian() async {
    final fatherCtrl = TextEditingController(text: fatherName.value);
    final motherCtrl = TextEditingController(text: motherName.value);
    final confirmed = await _showEditDialog(
      title: 'Edit Guardian Info',
      fields: [
        _EditField('Father Name', fatherCtrl),
        _EditField('Mother Name', motherCtrl),
      ],
    );
    if (!confirmed) return;
    await _saveProfileUpdates({
      'fatherName': fatherCtrl.text.trim(),
      'motherName': motherCtrl.text.trim(),
    });
  }
  Future<void> viewAllDocuments() async => loadProfile();
  Future<void> downloadDocument(String docName) async => loadProfile();
  void openSettings() => Get.toNamed(AppRoutes.PARENT_SETTINGS);
  void goToLibrary() => Get.toNamed(AppRoutes.PARENT_LIBRARY);

  void viewDocument(String docName) => Get.toNamed(
    AppRoutes.PARENT_DOCUMENT_VIEWER,
    arguments: {'document': docName},
  );

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  Future<bool> _showEditDialog({
    required String title,
    required List<_EditField> fields,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: f.controller,
                      decoration: InputDecoration(
                        labelText: f.label,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          Obx(
            () => FilledButton(
              onPressed: isSaving.value ? null : () => Get.back(result: true),
              child: Text(isSaving.value ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
      barrierDismissible: !isSaving.value,
    );
    return result == true;
  }

  Future<void> _saveProfileUpdates(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      await _profileService.updateProfileHub(
        data,
        childId: _parentContext.selectedChildId.value,
      );
      await loadProfile();
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isSaving.value = false;
    }
  }
}

class _EditField {
  _EditField(this.label, this.controller);
  final String label;
  final TextEditingController controller;
}
