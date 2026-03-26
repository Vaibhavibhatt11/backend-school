import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_finance_service.dart';

class FeesController extends GetxController {
  final ParentFinanceService _financeService = Get.find<ParentFinanceService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = 'Alex Johnson'.obs;
  final studentGrade = 'Grade 5-B'.obs;
  final totalOutstanding = 1425.00.obs;
  final selectedTab = 0.obs; // 0: Pending, 1: Paid, 2: Overdue

  final invoices =
      [
        {
          'title': 'Tuition Fee',
          'subtitle': 'Quarter 4 • #INV-089',
          'amount': 1250.00,
          'dueDate': 'Oct 25',
          'type': 'pending',
        },
        {
          'title': 'Sports Club',
          'subtitle': 'Annual Membership • #INV-102',
          'amount': 175.00,
          'dueDate': 'Nov 10',
          'type': 'pending',
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
    loadFees();
  }

  Future<void> loadFees() async {
    isLoading.value = true;
    try {
      final data = await _financeService.getFees(
        childId: _parentContext.selectedChildId.value,
      );
      if (data['studentName'] != null) {
        studentName.value = data['studentName'].toString();
      }
      if (data['studentGrade'] != null) {
        studentGrade.value = data['studentGrade'].toString();
      }
      final outstanding = data['totalOutstanding'];
      if (outstanding is num) {
        totalOutstanding.value = outstanding.toDouble();
      }
      final apiInvoices = data['invoices'];
      if (apiInvoices is List) {
        invoices.assignAll(
          apiInvoices.whereType<Map>().map((e) => Map<String, Object>.from(e)),
        );
      }
      final apiOverdue = data['overdueInvoices'];
      if (apiOverdue is List) {
        overdueInvoices.assignAll(
          apiOverdue.whereType<Map>().map((e) => Map<String, Object>.from(e)),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  final overdueInvoices =
      [
        {'title': 'Library Fine', 'amount': 15.00, 'dueDate': 'Sept 12'},
      ].obs;

  void goToInvoiceDetail(String invoiceId) {
    Get.toNamed(AppRoutes.PARENT_INVOICE_DETAIL, arguments: {'id': invoiceId});
  }

  void viewDetails(String id) {
    Get.toNamed(AppRoutes.PARENT_INVOICE_DETAIL, arguments: {'id': id});
  }

  void payNow(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Payment'),
        content: const Text('Payment gateway will be integrated soon.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  void quickPayAll() {
    Get.dialog(
      AlertDialog(
        title: const Text('Quick Pay'),
        content: const Text('Bulk payment feature coming soon.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  void goToHistory() {
    Get.dialog(
      AlertDialog(
        title: const Text('History'),
        content: const Text('Invoice history will be shown here.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
