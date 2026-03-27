import 'package:get/get.dart';
import '../../../../common/routes/common_routes_screens.dart';
import '../../../services/app_storage.dart';
import '../../../../common/services/auth_service.dart';
import '../../../../common/services/session_storage_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_settings_service.dart';

class SettingsController extends GetxController {
  final _storage = AppStorage();
  final SessionStorageService _sessionStorage = Get.find<SessionStorageService>();
  final ParentSettingsService _settingsService = Get.find<ParentSettingsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final userName = 'Parent User'.obs;
  final userRole = 'Parent'.obs;
  final userId = '-'.obs;
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
      final loginResponse = await _sessionStorage.getLoginResponse();
      final dataRoot = loginResponse?['data'];
      if (dataRoot is Map<String, dynamic>) {
        final user = dataRoot['user'];
        if (user is Map<String, dynamic>) {
          userName.value = user['fullName']?.toString() ?? userName.value;
          userRole.value = user['role']?.toString() ?? userRole.value;
          userId.value = user['id']?.toString() ?? userId.value;
        }
      }

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

  Future<void> logout() async {
    await Get.find<AuthService>().logout();
    _storage.clearAll();
    Get.offAllNamed(CommonScreenRoutes.loginScreen);
  }

  Future<void> deleteAccount() async {
    await Get.find<AuthService>().logout();
    _storage.clearAll();
    Get.offAllNamed(CommonScreenRoutes.loginScreen);
  }

  void goToPersonalInfo() {}
  void goToPasswordSecurity() {}
  void goToHelpCenter() {}
  void goToPrivacyPolicy() {}
}
