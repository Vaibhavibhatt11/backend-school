import 'package:get/get.dart';
import 'models/fee_models.dart';

class StudentFeesController extends GetxController {
  final RxDouble pendingDues = 0.0.obs;
  final RxBool hasScholarship = false.obs;

  final RxList<UpcomingFee> upcomingFees = <UpcomingFee>[].obs;
  final RxList<PaidFee> paidFees = <PaidFee>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    upcomingFees.assignAll([
      UpcomingFee(
        id: 'u1',
        title: 'Tuition fee – Term 2',
        amount: 12500,
        dueDate: now.add(const Duration(days: 14)),
        description: 'Academic term 2 tuition',
      ),
      UpcomingFee(
        id: 'u2',
        title: 'Transport fee – March',
        amount: 2500,
        dueDate: now.add(const Duration(days: 7)),
      ),
      UpcomingFee(
        id: 'u3',
        title: 'Library & lab fee',
        amount: 800,
        dueDate: now.add(const Duration(days: 21)),
      ),
    ]);
    paidFees.assignAll([
      PaidFee(
        id: 'p1',
        title: 'Tuition fee – Term 1',
        amount: 12500,
        paidDate: now.subtract(const Duration(days: 45)),
        receiptId: 'RCP-2024-001',
      ),
      PaidFee(
        id: 'p2',
        title: 'Transport fee – Feb',
        amount: 2500,
        paidDate: now.subtract(const Duration(days: 20)),
        receiptId: 'RCP-2024-002',
      ),
      PaidFee(
        id: 'p3',
        title: 'Admission fee',
        amount: 5000,
        paidDate: now.subtract(const Duration(days: 120)),
        receiptId: 'RCP-2023-015',
      ),
    ]);
    pendingDues.value = upcomingFees.fold<double>(0, (s, f) => s + f.amount);
  }

  void payFee(String feeId) {
    // Placeholder: in real app would open payment gateway
    Get.snackbar('Pay fee', 'Payment flow would open for $feeId');
  }

  void downloadReceipt(String feeId) {
    // Placeholder: in real app would generate/download PDF
    Get.snackbar('Download receipt', 'Receipt download would start for $feeId');
  }
}
