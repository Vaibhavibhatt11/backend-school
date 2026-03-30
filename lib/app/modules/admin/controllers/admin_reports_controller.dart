import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';

class AdminReportsController extends GetxController {
  AdminReportsController(this._adminService);

  final AdminService _adminService;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedRange = 'This Month'.obs;
  final selectedClass = 'All Classes'.obs;
  final classOptions = <String>['All Classes'].obs;
  final attendanceBadge = '0% Attendance'.obs;
  final feeOutstanding = 0.0.obs;
  final collectionTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([
        _loadClasses(),
        _loadAttendanceReport(),
        _loadFeesReport(),
      ]);
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadClasses() async {
    final data = await _adminService.getClasses(page: 1, limit: 100);
    final items = data['items'];
    final options = <String>['All Classes'];
    if (items is List) {
      for (final item in items.whereType<Map>()) {
        final name = (item['name'] ?? '').toString().trim();
        final section = (item['section'] ?? '').toString().trim();
        final value = section.isNotEmpty ? '$name-$section' : name;
        if (value.isNotEmpty && !options.contains(value)) {
          options.add(value);
        }
      }
    }
    classOptions.assignAll(options);
    if (!classOptions.contains(selectedClass.value)) {
      selectedClass.value = classOptions.first;
    }
  }

  Future<void> _loadAttendanceReport() async {
    final range = _dateRange();
    final now = range.end;
    final from = range.start;
    final data = await _adminService.getAttendanceReport(
      dateFrom: from.toIso8601String(),
      dateTo: now.toIso8601String(),
    );
    final summary = data['summary'];
    int present = 0;
    int late = 0;
    int absent = 0;
    if (summary is Map) {
      for (final row in summary.values.whereType<Map>()) {
        present += int.tryParse('${row['PRESENT'] ?? 0}') ?? 0;
        late += int.tryParse('${row['LATE'] ?? 0}') ?? 0;
        absent += int.tryParse('${row['ABSENT'] ?? 0}') ?? 0;
      }
    }
    final total = present + late + absent;
    final pct = total > 0 ? (((present + late) / total) * 100).round() : 0;
    attendanceBadge.value = '$pct% Attendance';
  }

  Future<void> _loadFeesReport() async {
    final range = _dateRange();
    final now = range.end;
    final from = range.start;
    final data = await _adminService.getFeesReport(
      dateFrom: from.toIso8601String(),
      dateTo: now.toIso8601String(),
    );
    final invoices = data['invoices'] as Map<String, dynamic>? ?? const {};
    final collections = data['collections'] as Map<String, dynamic>? ?? const {};
    final totalDue = (invoices['totalDue'] as num?)?.toDouble() ?? 0;
    final totalPaid = (invoices['totalPaid'] as num?)?.toDouble() ?? 0;
    feeOutstanding.value = totalDue - totalPaid;
    collectionTotal.value = (collections['total'] as num?)?.toDouble() ?? 0;
  }

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
                loadReports();
              },
            ),
            ListTile(
              title: Text('Last Month'),
              onTap: () {
                selectedRange.value = 'Last Month';
                Get.back();
                loadReports();
              },
            ),
            ListTile(
              title: Text('This Year'),
              onTap: () {
                selectedRange.value = 'This Year';
                Get.back();
                loadReports();
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
            ...classOptions.map(
              (value) => ListTile(
                title: Text(value),
                onTap: () {
                  selectedClass.value = value;
                  Get.back();
                },
              ),
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
    AppToast.show('Collected: \$${collectionTotal.value.toStringAsFixed(2)}');
  }

  DateTimeRange _dateRange() {
    final now = DateTime.now();
    switch (selectedRange.value) {
      case 'Last Month':
        final from = DateTime(now.year, now.month - 1, 1);
        final to = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(start: from, end: to);
      case 'This Year':
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: now);
      default:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    }
  }
}
