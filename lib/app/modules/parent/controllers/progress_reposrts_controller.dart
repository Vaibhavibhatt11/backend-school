import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressReportsController extends GetxController {
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
