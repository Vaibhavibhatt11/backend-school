import 'package:get/get.dart';

class FinanceHubController extends GetxController {
  final selectedTab = 'structure'.obs;

  final feeStructure = <Map<String, String>>[
    {'head': 'Tuition Fee', 'amount': '1800'},
    {'head': 'Transport Fee', 'amount': '650'},
    {'head': 'Activity Fee', 'amount': '300'},
  ].obs;

  final feePayments = <Map<String, String>>[
    {'invoice': 'INV-1021', 'amount': '1250', 'status': 'Paid'},
    {'invoice': 'INV-1094', 'amount': '900', 'status': 'Pending'},
  ].obs;

  final paymentHistory = <Map<String, String>>[
    {'date': '05 Jan 2026', 'amount': '1200', 'mode': 'UPI'},
    {'date': '07 Dec 2025', 'amount': '1200', 'mode': 'Card'},
  ].obs;

  final receipts = <Map<String, String>>[
    {'receiptNo': 'RCPT-8001', 'invoice': 'INV-1021'},
    {'receiptNo': 'RCPT-7894', 'invoice': 'INV-0982'},
  ].obs;

  final pendingDues = <Map<String, String>>[
    {'title': 'Term 2 Tuition', 'amount': '900', 'due': '20 Feb 2026'},
  ].obs;

  final scholarship = <Map<String, String>>[
    {'scheme': 'Merit Scholarship', 'amount': '400', 'status': 'Active'},
  ].obs;

  final paymentNotifications = <Map<String, String>>[
    {'title': 'Payment reminder', 'message': 'INV-1094 due in 3 days'},
    {'title': 'Receipt generated', 'message': 'RCPT-8001 available for download'},
  ].obs;

  void changeTab(String tab) => selectedTab.value = tab;
}
