import 'package:erp_frontend/app/modules/admin/controllers/admin_resources_controller.dart';
import 'package:erp_frontend/app/modules/librarian/controllers/librarian_library_controller.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:get/get.dart';

class LibrarianBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminResourcesController>()) {
      Get.lazyPut<AdminResourcesController>(
        () => AdminResourcesController(Get.find<AdminService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LibrarianLibraryController>()) {
      Get.put(LibrarianLibraryController(), permanent: true);
    }
  }
}
