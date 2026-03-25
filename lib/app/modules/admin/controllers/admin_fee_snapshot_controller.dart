import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeeCategory {
  final String name;
  final double due;
  final double collected;
  final Color color;
  FeeCategory(this.name, this.due, this.collected, this.color);
}

class AdminFeeSnapshotController extends GetxController {
  final totalDues = 1200000.0;
  final collected = 816000.0;
  final pending = 383600.0;
  final overallPercent = 68.0;
  final categories = [
    FeeCategory('Tuition Fees', 600000, 480000, const Color(0xFF137FEC)),
    FeeCategory('Transport Fees', 250000, 125000, Colors.amber),
    FeeCategory('Lab Fees', 150000, 135000, Colors.purple),
  ];

  void onViewDetails() {
    Get.snackbar('Category', 'View all categories');
  }

  void onSendReminders() {
    Get.snackbar('Reminders', 'Sent to defaulters');
  }
}
