import 'package:get/get.dart';
import '../../../../common/services/parent/parent_finance_service.dart';

class InvoiceDetailController extends GetxController {
  final ParentFinanceService _financeService = Get.find<ParentFinanceService>();

  final isLoading = false.obs;
  final invoiceId = ''.obs;
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
        studentPhotoUrl.value =
            (map['studentPhotoUrl'] ?? map['photoUrl'] ?? map['avatarUrl'] ?? studentPhotoUrl.value)
                .toString();
        dueDate.value = map['dueDate']?.toString() ?? dueDate.value;
        final due = map['totalDue'];
        if (due is num) totalDue.value = due.toDouble();
      }
      final history = data['paymentHistory'];
      if (history is List) {
        paymentHistory.assignAll(
          history.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void payBalance() {}
  void download() {}
}
