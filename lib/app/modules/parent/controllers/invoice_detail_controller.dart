import 'package:get/get.dart';
import '../../../../common/services/parent/parent_finance_service.dart';

class InvoiceDetailController extends GetxController {
  final ParentFinanceService _financeService = Get.find<ParentFinanceService>();

  final isLoading = false.obs;
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

  @override
  void onInit() {
    super.onInit();
    final argId = (Get.arguments is Map) ? Get.arguments['id']?.toString() : null;
    if (argId != null && argId.isNotEmpty) {
      invoiceId.value = argId;
      loadInvoice(argId);
    }
  }

  Future<void> loadInvoice(String id) async {
    isLoading.value = true;
    try {
      final data = await _financeService.getInvoiceById(id);
      final invoice = data['invoice'];
      if (invoice is Map) {
        final map = Map<String, dynamic>.from(invoice);
        status.value = map['status']?.toString() ?? status.value;
        issuedDate.value = map['issuedDate']?.toString() ?? issuedDate.value;
        studentName.value = map['studentName']?.toString() ?? studentName.value;
        studentDetail.value = map['studentDetail']?.toString() ?? studentDetail.value;
        dueDate.value = map['dueDate']?.toString() ?? dueDate.value;
        final due = map['totalDue'];
        if (due is num) totalDue.value = due.toDouble();
      }
      final history = data['paymentHistory'];
      if (history is List) {
        paymentHistory.assignAll(
          history.whereType<Map>().map((e) => Map<String, Object>.from(e)),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void payBalance() {}
  void download() {}
}
