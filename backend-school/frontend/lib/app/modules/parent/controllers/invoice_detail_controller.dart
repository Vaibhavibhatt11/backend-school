import 'package:get/get.dart';
import '../../../../common/services/parent/parent_finance_service.dart';

class InvoiceDetailController extends GetxController {
  final ParentFinanceService _financeService = Get.find<ParentFinanceService>();

  final isLoading = false.obs;
  final invoiceId = ''.obs;
  final invoiceRecordId = ''.obs;
  final status = ''.obs;
  final issuedDate = ''.obs;
  final studentName = ''.obs;
  final studentDetail = ''.obs;
  final studentPhotoUrl = ''.obs;
  final dueDate = ''.obs;
  final totalDue = 0.0.obs;

  final breakdown = <Map<String, dynamic>>[].obs;

  final subtotal = 0.0.obs;
  final tax = 0.0.obs;
  final total = 0.0.obs;

  final paymentHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final argId = (Get.arguments is Map)
        ? Get.arguments['id']?.toString()
        : null;
    if (argId != null && argId.isNotEmpty) {
      invoiceRecordId.value = argId;
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
        status.value = map['status']?.toString() ?? '';
        issuedDate.value =
            _formatDate(map['issueDate'] ?? map['issuedAt']) ?? '';
        studentName.value =
            (map['studentName'] ?? map['student']?['name'] ?? studentName.value)
                .toString();
        final classLabel = (map['studentClass'] ?? map['classLabel'] ?? '')
            .toString()
            .trim();
        final invoiceLabel = (map['invoiceNo'] ?? map['id'] ?? '').toString();
        studentDetail.value = [
          classLabel,
          invoiceLabel,
        ].where((value) => value.isNotEmpty).join(' - ');
        studentPhotoUrl.value =
            (map['studentPhotoUrl'] ??
                    map['photoUrl'] ??
                    map['avatarUrl'] ??
                    studentPhotoUrl.value)
                .toString();
        dueDate.value = _formatDate(map['dueDate']) ?? '';
        final amountDue = (map['amountDue'] as num?)?.toDouble() ?? 0.0;
        final amountPaid = (map['amountPaid'] as num?)?.toDouble() ?? 0.0;
        final outstanding = (amountDue - amountPaid).clamp(
          0.0,
          double.infinity,
        );
        totalDue.value = outstanding;
        invoiceRecordId.value = (map['id'] ?? id).toString();
        invoiceId.value = (map['invoiceNo'] ?? map['id'] ?? id).toString();
        subtotal.value = outstanding;
        tax.value = 0;
        total.value = outstanding;
        final rows = <Map<String, dynamic>>[];
        if (amountDue > 0) {
          rows.add({
            'item': (map['feeStructureName'] ?? map['invoiceNo'] ?? 'Invoice')
                .toString(),
            'description': (map['status'] ?? '').toString(),
            'amount': amountDue,
          });
        }
        if (amountPaid > 0) {
          rows.add({
            'item': 'Paid',
            'description': 'Payments received',
            'amount': -amountPaid,
          });
        }
        breakdown.assignAll(rows);
      }
      final history = data['paymentHistory'];
      if (history is List) {
        paymentHistory.assignAll(
          history.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      } else {
        paymentHistory.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  String? _formatDate(dynamic raw) {
    if (raw == null) return null;
    final d = DateTime.tryParse(raw.toString());
    if (d == null) return raw.toString();
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  Future<void> payBalance() async {
    if (invoiceRecordId.value.isEmpty) return;
    isLoading.value = true;
    try {
      await _financeService.payInvoiceBalance(invoiceRecordId.value);
      await loadInvoice(invoiceRecordId.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> download() async => loadInvoice(invoiceRecordId.value);
}
