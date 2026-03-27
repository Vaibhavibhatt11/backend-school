import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../services/app_storage.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_settings_service.dart';

class SettingsController extends GetxController {
  final _storage = AppStorage();
  final ParentSettingsService _settingsService = Get.find<ParentSettingsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final userName = 'Sarah Jenkins'.obs;
  final userRole = 'Parent'.obs;
  final userId = '8829-XJ'.obs;
  final faceIdEnabled = true.obs;
  final pushNotificationsEnabled = true.obs;
  final selectedLanguage = 'English (US)'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final data = await _settingsService.getSettings(
        childId: _parentContext.selectedChildId.value,
      );
      if (data['pushNotificationsEnabled'] is bool) {
        pushNotificationsEnabled.value = data['pushNotificationsEnabled'] as bool;
      }
      if (data['faceIdEnabled'] is bool) {
        faceIdEnabled.value = data['faceIdEnabled'] as bool;
      }
      if (data['selectedLanguage'] != null) {
        selectedLanguage.value = data['selectedLanguage'].toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFaceId(bool value) {
    faceIdEnabled.value = value;
    _saveSettings();
  }

  void togglePushNotifications(bool value) {
    pushNotificationsEnabled.value = value;
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      await _settingsService.updateSettings({
        'pushNotificationsEnabled': pushNotificationsEnabled.value,
        'faceIdEnabled': faceIdEnabled.value,
        'selectedLanguage': selectedLanguage.value,
      }, childId: _parentContext.selectedChildId.value);
    } catch (_) {
      // Keep local state even if backend update fails.
    }
  }

  void logout() {
    _storage.clearAll();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void deleteAccount() {
    // Placeholder until backend delete-account endpoint is integrated.
    _storage.clearAll();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void goToPersonalInfo() {}
  void goToPasswordSecurity() {}
  void goToHelpCenter() {}
  void goToPrivacyPolicy() {}
}
