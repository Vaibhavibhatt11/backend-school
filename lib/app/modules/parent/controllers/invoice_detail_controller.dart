import 'package:get/get.dart';

class InvoiceDetailController extends GetxController {
  final invoiceId = ''.obs;
  final status = 'Partially Paid'.obs;
  final issuedDate = 'Oct 15, 2023'.obs;
  final studentName = 'Alexander Thompson'.obs;
  final studentDetail = 'Grade 10-B • Roll No: 42'.obs;
  final dueDate = 'Oct 30, 2023'.obs;
  final totalDue = 1240.00.obs;

  final breakdown =
      [
        {
          'item': 'Tuition Fees',
          'description': 'Q3 Academic Cycle',
          'amount': 2400.00,
        },
        {
          'item': 'Transport',
          'description': 'Route 14 Service',
          'amount': 450.00,
        },
        {
          'item': 'Lab & Tech Fee',
          'description': 'Standard Lab Access',
          'amount': 150.00,
        },
        {
          'item': 'Merit Scholarship',
          'description': '15% Tuition Waiver',
          'amount': -360.00,
        },
      ].obs;

  final subtotal = 2640.00.obs;
  final tax = 132.00.obs;
  final total = 2772.00.obs;

  final paymentHistory =
      [
        {
          'ref': '#TXN_9021488',
          'amount': 1532.00,
          'date': 'Oct 18, 2023',
          'time': '10:42 AM',
          'method': 'Apple Pay',
        },
      ].obs;

  void payBalance() {}
  void download() {}
}
