import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/theme_service.dart';

class AdminSettingsController extends GetxController {
  final ThemeService _themeService = Get.find();
  final mfaEnabled = true.obs;
  final biometricEnabled = true.obs;
  final darkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    darkMode.value = _themeService.isDarkMode.value;
    ever(darkMode, (bool val) => _themeService.toggleTheme());
  }

  void goToAdminProfile() {
    Get.toNamed(AppRoutes.ADMIN_PROFILE);
  }

  void onMfaToggle(bool? value) {
    if (value != null) mfaEnabled.value = value;
    Get.snackbar('MFA', mfaEnabled.value ? 'Enabled' : 'Disabled');
  }

  void onBiometricToggle(bool? value) {
    if (value != null) biometricEnabled.value = value;
    Get.snackbar('Biometric', biometricEnabled.value ? 'Enabled' : 'Disabled');
  }

  void onOtpPreferences() {
    Get.snackbar('OTP', 'Change OTP preferences');
  }

  void onPushNotifications() {
    Get.snackbar('Notifications', 'Push notification settings');
  }

  void onLanguage() {
    Get.snackbar('Language', 'Change language');
  }

  void onPrivacyPolicy() {
    Get.snackbar('Privacy', 'Privacy policy');
  }

  void onTerms() {
    Get.snackbar('Terms', 'Terms of service');
  }

  void onLogout() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.SPLASH);
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
