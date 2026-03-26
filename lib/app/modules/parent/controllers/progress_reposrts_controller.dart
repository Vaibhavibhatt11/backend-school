import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class ProgressReportsController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = ''.obs;
  final studentClass = ''.obs;
  final academicYear = ''.obs;
  final selectedTerm = 0.obs; // 0: Term 2, 1: Term 1, etc.
  final gpa = 0.0.obs;
  final gpaChange = 0.0.obs;
  final attendance = 0.0.obs;
  final attendanceStatus = ''.obs;

  final subjects = <Map<String, dynamic>>[].obs;

  final attendanceDistribution = <String, int>{'present': 0, 'late': 0, 'absent': 0}.obs;

  final feeHistory = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProgressReport();
  }

  Future<void> loadProgressReport() async {
    isLoading.value = true;
    try {
      final data = await _academicsService.getProgressReports(
        childId: _parentContext.selectedChildId.value,
      );
      studentName.value = data['studentName']?.toString() ?? studentName.value;
      studentClass.value = data['studentClass']?.toString() ?? studentClass.value;
      academicYear.value = data['academicYear']?.toString() ?? academicYear.value;
      if (data['selectedTerm'] != null) {
        selectedTerm.value = int.tryParse(data['selectedTerm'].toString()) ?? selectedTerm.value;
      }
      final gpaValue = data['gpa'];
      if (gpaValue is num) gpa.value = gpaValue.toDouble();
      final attendanceValue = data['attendance'];
      if (attendanceValue is num) attendance.value = attendanceValue.toDouble();
      final scores = data['subjectScores'];
      if (scores is List) {
        subjects.assignAll(scores.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      }
      final fees = data['feeHistory'];
      if (fees is List) {
        feeHistory.assignAll(fees.map((e) => int.tryParse(e.toString()) ?? 0));
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setTerm(int index) => selectedTerm.value = index;
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
}
