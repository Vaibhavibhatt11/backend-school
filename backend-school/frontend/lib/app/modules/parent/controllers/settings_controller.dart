import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../common/routes/common_routes_screens.dart';
import '../../../services/app_storage.dart';
import '../../../../common/services/auth_service.dart';
import '../../../../common/services/session_storage_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_settings_service.dart';
import '../views/personal_information_view.dart';
import '../views/settings_option_view.dart';

class SettingsController extends GetxController {
  final _storage = AppStorage();
  final SessionStorageService _sessionStorage =
      Get.find<SessionStorageService>();
  final ParentSettingsService _settingsService =
      Get.find<ParentSettingsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final userName = 'Parent User'.obs;
  final userRole = 'Parent'.obs;
  final userId = '-'.obs;
  final pushNotificationsEnabled = true.obs;
  final selectedLanguage = 'English (US)'.obs;
  final emailNotificationsEnabled = true.obs;
  final smsNotificationsEnabled = false.obs;
  final profileVisibilityPrivate = true.obs;
  final analyticsSharingEnabled = false.obs;
  final languageOptions = <String>[
    'English (US)',
    'English (UK)',
    'Hindi',
    'Gujarati',
  ];
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadSettings(),
    );
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
      _applySettingsData(data);
    } finally {
      isLoading.value = false;
    }
  }

  void togglePushNotifications(bool value) {
    pushNotificationsEnabled.value = value;
    _saveSettings();
  }

  void toggleEmailNotifications(bool value) {
    emailNotificationsEnabled.value = value;
    _saveSettings();
  }

  void toggleSmsNotifications(bool value) {
    smsNotificationsEnabled.value = value;
    _saveSettings();
  }

  void toggleProfilePrivacy(bool value) {
    profileVisibilityPrivate.value = value;
    _saveSettings();
  }

  void toggleAnalyticsSharing(bool value) {
    analyticsSharingEnabled.value = value;
    _saveSettings();
  }

  void updateLanguage(String language) {
    selectedLanguage.value = language;
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final data = await _settingsService.updateSettings({
        'pushNotificationsEnabled': pushNotificationsEnabled.value,
        'emailNotificationsEnabled': emailNotificationsEnabled.value,
        'smsNotificationsEnabled': smsNotificationsEnabled.value,
        'profileVisibilityPrivate': profileVisibilityPrivate.value,
        'analyticsSharingEnabled': analyticsSharingEnabled.value,
        'selectedLanguage': selectedLanguage.value,
      }, childId: _parentContext.selectedChildId.value);
      _applySettingsData(data);
    } catch (_) {
      // Keep local state even if backend update fails.
    }
  }

  void _applySettingsData(Map<String, dynamic> data) {
    if (data['pushNotificationsEnabled'] is bool) {
      pushNotificationsEnabled.value = data['pushNotificationsEnabled'] as bool;
    }
    if (data['emailNotificationsEnabled'] is bool) {
      emailNotificationsEnabled.value =
          data['emailNotificationsEnabled'] as bool;
    }
    if (data['smsNotificationsEnabled'] is bool) {
      smsNotificationsEnabled.value = data['smsNotificationsEnabled'] as bool;
    }
    if (data['profileVisibilityPrivate'] is bool) {
      profileVisibilityPrivate.value = data['profileVisibilityPrivate'] as bool;
    }
    if (data['analyticsSharingEnabled'] is bool) {
      analyticsSharingEnabled.value = data['analyticsSharingEnabled'] as bool;
    }
    if (data['selectedLanguage'] != null) {
      selectedLanguage.value = data['selectedLanguage'].toString();
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

  void goToPersonalInfo() {
    Get.to(() => const PersonalInformationView());
  }

  void goToPasswordSecurity() {
    Get.to(
      () => const SettingsOptionView(
        title: 'Password & Security',
        description: 'Update password and review account security preferences.',
        icon: Icons.lock,
      ),
    );
  }

  void goToHelpCenter() {
    Get.to(
      () => const SettingsOptionView(
        title: 'Help Center',
        description:
            'Get support, FAQs, and guidance for using the parent module.',
        icon: Icons.help_outline,
      ),
    );
  }

  void goToPrivacyPolicy() {
    Get.to(
      () => const SettingsOptionView(
        title: 'Privacy Policy',
        description: 'Read how your data is handled and protected in this app.',
        icon: Icons.description,
      ),
    );
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
