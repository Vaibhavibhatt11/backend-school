import 'package:erp_frontend/app/modules/admin/controllers/admin_operations_controller.dart';
import 'package:get/get.dart';

class HostelWardenController extends GetxController {
  AdminOperationsController get operations => Get.find<AdminOperationsController>();

  @override
  void onInit() {
    super.onInit();
    _loadHostelData();
  }

  Future<void> _loadHostelData() async {
    operations.currentTab.value = 0;
    await operations.loadCurrentTab(force: true);
  }

  Future<void> refreshData() => _loadHostelData();
}
