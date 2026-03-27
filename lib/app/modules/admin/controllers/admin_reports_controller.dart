import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';

class AdminReportsController extends GetxController {
  final selectedRange = 'This Month'.obs;
  final selectedClass = 'Grade 10-A'.obs;

  // void onRangeTap() {
  //   // show dialog to select range
  //   Get.snackbar('Filter', 'Select range');
  // }

  // void onClassTap() {
  //   Get.snackbar('Filter', 'Select class');
  // }

  void onViewDetailedLog() {
    AppToast.show('View detailed log');
  }

  // void onPDFExport(String type) {
  //   Get.snackbar('Export', '$type PDF');
  // }

  void onRangeTap() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('This Month'),
              onTap: () {
                selectedRange.value = 'This Month';
                Get.back();
              },
            ),
            ListTile(
              title: Text('Last Month'),
              onTap: () {
                selectedRange.value = 'Last Month';
                Get.back();
              },
            ),
            ListTile(
              title: Text('This Year'),
              onTap: () {
                selectedRange.value = 'This Year';
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void onClassTap() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Grade 10-A'),
              onTap: () {
                selectedClass.value = 'Grade 10-A';
                Get.back();
              },
            ),
            ListTile(
              title: Text('Grade 10-B'),
              onTap: () {
                selectedClass.value = 'Grade 10-B';
                Get.back();
              },
            ),
            ListTile(
              title: Text('Grade 11-A'),
              onTap: () {
                selectedClass.value = 'Grade 11-A';
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void onPDFExport(String type) {
    // Simulate PDF generation
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating $type PDF...'),
          ],
        ),
      ),
    );
    Future.delayed(Duration(seconds: 2), () {
      Get.back();
      AppToast.show('$type PDF saved to downloads');
    });
  }

  void onExcelExport(String type) {
    AppToast.show('$type Excel');
  }

  void onCollectionAnalysis() {
    AppToast.show('Collection analysis');
  }
}
