import 'package:get/get.dart';

import '../../../common/api/api_client.dart';
import '../../../common/services/auth_service.dart';
import '../../../common/services/session_storage_service.dart';
import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SessionStorageService>()) {
      Get.lazyPut<SessionStorageService>(() => SessionStorageService(), fenix: true);
    }
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(Get.find<SessionStorageService>()), fenix: true);
    }
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(
        () => AuthService(Get.find<ApiClient>(), Get.find<SessionStorageService>()),
        fenix: true,
      );
    }
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

