import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/utils/app_toast.dart';

class ProgressReportsController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final studentName = ''.obs;
  final studentClass = ''.obs;
  final studentPhotoUrl = ''.obs;
  final academicYear = ''.obs;
  final selectedTerm = ''.obs;
  final terms = <String>[].obs;
  final gpa = 0.0.obs;
  final gpaChange = 0.0.obs;
  final attendance = 0.0.obs;
  final attendanceStatus = ''.obs;

  final subjects = <Map<String, dynamic>>[].obs;

  final attendanceDistribution = <String, int>{'present': 0, 'late': 0, 'absent': 0}.obs;

  final feeHistory = <int>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadProgressReport(),
    );
    loadProgressReport();
  }

  Future<void> loadProgressReport() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _academicsService.getProgressReports(
        childId: _parentContext.selectedChildId.value,
      );
      studentName.value = data['studentName']?.toString() ?? studentName.value;
      studentClass.value = data['studentClass']?.toString() ?? studentClass.value;
      studentPhotoUrl.value =
          (data['photoUrl'] ?? data['avatarUrl'] ?? data['studentPhotoUrl'] ?? studentPhotoUrl.value)
              .toString();
      academicYear.value = data['academicYear']?.toString() ?? academicYear.value;
      final selected = data['selectedTerm']?.toString().trim();
      if (selected != null && selected.isNotEmpty) {
        selectedTerm.value = selected;
      }
      final apiTerms = data['terms'];
      if (apiTerms is List) {
        final parsed = apiTerms.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
        terms.assignAll(parsed);
      } else if (selectedTerm.value.isNotEmpty) {
        terms.assignAll([selectedTerm.value]);
      } else {
        terms.clear();
      }
      final gpaValue = data['gpa'];
      if (gpaValue is num) gpa.value = gpaValue.toDouble();
      final attendanceValue = data['attendance'];
      if (attendanceValue is num) attendance.value = attendanceValue.toDouble();
      if (data['attendanceStats'] is Map) {
        final stats = data['attendanceStats'] as Map;
        attendanceDistribution.assignAll({
          'present': int.tryParse('${stats['present'] ?? 0}') ?? 0,
          'late': int.tryParse('${stats['late'] ?? 0}') ?? 0,
          'absent': int.tryParse('${stats['absent'] ?? 0}') ?? 0,
        });
      }
      final scores = data['subjectScores'];
      if (scores is List) {
        subjects.assignAll(scores.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      }
      final fees = data['feeHistory'];
      if (fees is List) {
        feeHistory.assignAll(fees.map((e) => int.tryParse(e.toString()) ?? 0));
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void setTerm(String term) => selectedTerm.value = term;
  void viewFullMarksheet() {
    Get.dialog(
      AlertDialog(
        title: const Text('Marksheet'),
        content: const Text('Full marksheet will be displayed here.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  void payNow() {
    Get.dialog(
      AlertDialog(
        title: const Text('Payment'),
        content: const Text('Redirecting to payment gateway...'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
