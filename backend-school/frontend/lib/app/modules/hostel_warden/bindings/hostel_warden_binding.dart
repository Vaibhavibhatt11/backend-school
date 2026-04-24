import 'package:erp_frontend/app/modules/admin/controllers/admin_operations_controller.dart';
import 'package:erp_frontend/app/modules/hostel_warden/controllers/hostel_warden_controller.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:get/get.dart';

class HostelWardenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminOperationsController>()) {
      Get.lazyPut<AdminOperationsController>(
        () => AdminOperationsController(Get.find<AdminService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<HostelWardenController>()) {
      Get.put(HostelWardenController(), permanent: true);
    }
  }
}
