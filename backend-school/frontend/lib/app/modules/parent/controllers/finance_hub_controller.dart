import 'package:get/get.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_finance_service.dart';

class FinanceHubController extends GetxController {
  final ParentFinanceService _financeService = Get.find<ParentFinanceService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final selectedTab = 'structure'.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final feeStructure = <Map<String, String>>[].obs;
  final feePayments = <Map<String, String>>[].obs;
  final paymentHistory = <Map<String, String>>[].obs;
  final receipts = <Map<String, String>>[].obs;
  final pendingDues = <Map<String, String>>[].obs;
  final scholarship = <Map<String, String>>[].obs;
  final paymentNotifications = <Map<String, String>>[].obs;

  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadFinanceHub(),
    );
    loadFinanceHub();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  void changeTab(String tab) => selectedTab.value = tab;

  Future<void> loadFinanceHub() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _financeService.getFinanceHub(
        childId: _parentContext.selectedChildId.value,
      );
      feeStructure.assignAll(_mapStringRows(data['feeStructure']));
      feePayments.assignAll(_mapStringRows(data['feePayments']));
      paymentHistory.assignAll(_mapStringRows(data['paymentHistory']));
      receipts.assignAll(_mapStringRows(data['receipts']));
      pendingDues.assignAll(_mapStringRows(data['pendingDues']));
      scholarship.assignAll(_mapStringRows(data['scholarship']));
      paymentNotifications.assignAll(
        _mapStringRows(data['paymentNotifications']),
      );
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      feeStructure.clear();
      feePayments.clear();
      paymentHistory.clear();
      receipts.clear();
      pendingDues.clear();
      scholarship.clear();
      paymentNotifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, String>> _mapStringRows(dynamic raw) {
    if (raw is! List) return const <Map<String, String>>[];
    return raw.whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      return m.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    }).toList();
  }
}
