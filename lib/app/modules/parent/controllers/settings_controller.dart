import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../services/app_storage.dart';
import '../../../services/theme_service.dart';

class SettingsController extends GetxController {
  final _storage = AppStorage();
  final _themeService = Get.find<ThemeService>();

  final userName = 'Sarah Jenkins'.obs;
  final userRole = 'Parent'.obs;
  final userId = '8829-XJ'.obs;
  final faceIdEnabled = true.obs;
  final pushNotificationsEnabled = true.obs;
  final selectedLanguage = 'English (US)'.obs;
  final darkModeOption = 'Auto'.obs; // 'Auto', 'On', 'Off'

  void toggleFaceId(bool value) => faceIdEnabled.value = value;
  void togglePushNotifications(bool value) =>
      pushNotificationsEnabled.value = value;

  void setDarkMode(String option) {
    darkModeOption.value = option;
    if (option == 'On') {
      _themeService.isDarkMode.value = true;
    } else if (option == 'Off') {
      _themeService.isDarkMode.value = false;
    } else {
      // Auto: follow system? For now, just toggle based on current
      // We'll keep as is
    }
  }

  void logout() {
    _storage.clearAll();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void goToPersonalInfo() {}
  void goToPasswordSecurity() {}
  void goToHelpCenter() {}
  void goToPrivacyPolicy() {}
}
