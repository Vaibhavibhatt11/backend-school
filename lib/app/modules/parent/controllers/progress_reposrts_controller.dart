import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class ProgressReportsController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = 'Alex Johnson'.obs;
  final studentClass = 'Grade 10-B • Rank: 04/42'.obs;
  final academicYear = 'Academic Year 2023-24'.obs;
  final selectedTerm = 0.obs; // 0: Term 2, 1: Term 1, etc.
  final gpa = 3.82.obs;
  final gpaChange = 0.12.obs;
  final attendance = 94.2.obs;
  final attendanceStatus = 'High'.obs;

  final subjects =
      [
        {'name': 'Mathematics', 'score': 92, 'avg': 85},
        {'name': 'Science', 'score': 88, 'avg': 82},
        {'name': 'English', 'score': 76, 'avg': 78},
      ].obs;

  final attendanceDistribution = {'present': 172, 'late': 8, 'absent': 2}.obs;

  final feeHistory = [75, 100, 60, 40, 20].obs; // 5 items ✅

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
        subjects.assignAll(scores.whereType<Map>().map((e) => Map<String, Object>.from(e)));
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
