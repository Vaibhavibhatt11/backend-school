import 'package:get/get.dart';
import '../../../app/services/theme_service.dart';

class StudentSettingsController extends GetxController {
  final ThemeService _themeService = Get.find<ThemeService>();
  final RxBool notificationsEnabled = true.obs;
  final RxBool darkModeEnabled = false.obs;
  final RxBool biometricEnabled = false.obs;
  final RxBool examReminderEnabled = true.obs;
  final RxBool homeworkReminderEnabled = true.obs;
  final RxString language = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    darkModeEnabled.value = _themeService.isDarkMode.value;
    ever(_themeService.isDarkMode, (bool value) {
      darkModeEnabled.value = value;
    });
  }

  void toggleDarkMode(bool value) {
    if (_themeService.isDarkMode.value != value) {
      _themeService.toggleTheme();
    }
    darkModeEnabled.value = _themeService.isDarkMode.value;
  }
}
