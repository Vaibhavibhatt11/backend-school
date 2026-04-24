import 'package:get/get.dart';
import '../../../common/utils/app_toast.dart';
import 'models/fee_models.dart';

class StudentFeesController extends GetxController {
  final RxDouble pendingDues = 0.0.obs;
  final RxBool hasScholarship = false.obs;

  final RxList<UpcomingFee> upcomingFees = <UpcomingFee>[].obs;
  final RxList<PaidFee> paidFees = <PaidFee>[].obs;

  @override
  void onInit() {
    super.onInit();
    upcomingFees.clear();
    paidFees.clear();
    pendingDues.value = 0;
  }

  void payFee(String feeId) {
    AppToast.show('Payment integration is not configured yet.');
  }

  void downloadReceipt(String feeId) {
    AppToast.show('Receipt download is not configured yet.');
  }
}
