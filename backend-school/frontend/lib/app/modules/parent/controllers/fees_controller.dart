import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_finance_service.dart';

class FeesController extends GetxController {
  final ParentFinanceService _financeService = Get.find<ParentFinanceService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = ''.obs;
  final studentGrade = ''.obs;
  final totalOutstanding = 0.0.obs;
  final selectedTab = 0.obs; // 0: Pending, 1: Paid, 2: Overdue
  final errorMessage = ''.obs;

  final invoices = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadFees(),
    );
    loadFees();
  }

  Future<void> loadFees() async {
    isLoading.value = true;
    errorMessage.value = '';
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
          apiInvoices.whereType<Map>().map((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              'id': (m['id'] ?? m['_id'] ?? '').toString(),
              'title': (m['title'] ?? m['name'] ?? 'Invoice').toString(),
              'subtitle': (m['subtitle'] ?? m['invoiceNo'] ?? '').toString(),
              'amount': m['amount'],
              'dueDate': (m['dueDate'] ?? '').toString(),
              'type': (m['type'] ?? 'pending').toString(),
            };
          }),
        );
      }
      final apiOverdue = data['overdueInvoices'];
      if (apiOverdue is List) {
        overdueInvoices.assignAll(
          apiOverdue.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  final overdueInvoices = <Map<String, dynamic>>[].obs;

  void goToInvoiceDetail(String invoiceId) {
    Get.toNamed(AppRoutes.PARENT_INVOICE_DETAIL, arguments: {'id': invoiceId});
  }

  void viewDetails(String id) {
    Get.toNamed(AppRoutes.PARENT_INVOICE_DETAIL, arguments: {'id': id});
  }

  Future<void> payNow(String id) async {
    if (id.isEmpty) return;
    try {
      isLoading.value = true;
      await _financeService.payInvoiceBalance(id);
      await loadFees();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> quickPayAll() async {
    if (invoices.isEmpty) return;
    try {
      isLoading.value = true;
      await _financeService.quickPayAllInvoices(
        childId: _parentContext.selectedChildId.value,
      );
      await loadFees();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  void goToHistory() {
    selectedTab.value = 1;
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
