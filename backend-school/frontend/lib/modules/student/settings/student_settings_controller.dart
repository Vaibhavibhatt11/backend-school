import 'package:get/get.dart';
import '../../../app/services/app_storage.dart';
import '../../../common/routes/common_routes_screens.dart';
import '../../../common/services/session_storage_service.dart';

class StudentSettingsController extends GetxController {
  final SessionStorageService _sessionStorage = Get.find<SessionStorageService>();
  final AppStorage _appStorage = AppStorage();
  final RxBool notificationsEnabled = true.obs;
  final RxBool examReminderEnabled = true.obs;
  final RxBool homeworkReminderEnabled = true.obs;
  final RxString language = 'English'.obs;

  Future<void> logout() async {
    await _sessionStorage.clearSession();
    _appStorage.clearAll();
    Get.offAllNamed(CommonScreenRoutes.loginScreen);
  }

  Future<void> deleteAccount() async {
    // Placeholder until delete-account API is available.
    await _sessionStorage.clearSession();
    _appStorage.clearAll();
    Get.offAllNamed(CommonScreenRoutes.loginScreen);
  }
}
