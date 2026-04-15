import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/auth_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/routes/common_routes_screens.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/app_storage.dart';

class AdminSettingsController extends GetxController {
  AdminSettingsController(this._adminService);

  final AdminService _adminService;
  final AppStorage _storage = AppStorage();
  final isLoading = false.obs;
  final adminName = 'Admin'.obs;
  final adminSubtitle = ''.obs;
  final adminInitials = 'AD'.obs;
  final sessionInfo = ''.obs;
  final appVersion = 'v2.4.9'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final profileData = await _adminService.getProfileMe();
      final settingsData = await _adminService.getSchoolSettings();
      final profile = profileData['profile'] as Map<String, dynamic>? ?? const {};
      final settings = settingsData['settings'] as Map<String, dynamic>? ?? const {};
      adminName.value = profile['fullName']?.toString() ?? 'Admin';
      adminSubtitle.value =
          '${settings['name'] ?? 'School'} • ${profile['role'] ?? 'SCHOOLADMIN'}';
      final parts = adminName.value
          .split(' ')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e[0].toUpperCase())
          .take(2)
          .toList();
      adminInitials.value = parts.isNotEmpty ? parts.join() : 'AD';
      final lastLogin = profile['lastLoginAt']?.toString();
      sessionInfo.value = (lastLogin != null && lastLogin.isNotEmpty)
          ? 'Last login: $lastLogin'
          : 'Last login: unavailable';
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void goToAdminProfile() {
    Get.toNamed(AppRoutes.ADMIN_PROFILE);
  }

  void onPushNotifications() {
    AppToast.show('Push notification settings will be available soon.');
  }

  void onLanguage() {
    AppToast.show('Language settings will be available soon.');
  }

  void onPrivacyPolicy() {
    AppToast.show('Privacy Policy page will be available soon.');
  }

  void onTerms() {
    AppToast.show('Terms of Service page will be available soon.');
  }

  void onLogout() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await Get.find<AuthService>().logout();
              _storage.clearAll();
              Get.offAllNamed(CommonScreenRoutes.loginScreen);
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void onDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action will remove your local session and sign you out. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await Get.find<AuthService>().logout();
              _storage.clearAll();
              Get.offAllNamed(CommonScreenRoutes.loginScreen);
              AppToast.show('Account removed from this device.');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
