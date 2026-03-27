import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/app_storage.dart';

class AdminSettingsController extends GetxController {
  final AppStorage _storage = AppStorage();

  void goToAdminProfile() {
    Get.toNamed(AppRoutes.ADMIN_PROFILE);
  }

  void onPushNotifications() {
    AppToast.show('Push notification settings');
  }

  void onLanguage() {
    AppToast.show('Change language');
  }

  void onPrivacyPolicy() {
    AppToast.show('Privacy policy');
  }

  void onTerms() {
    AppToast.show('Terms of service');
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
              _storage.clearAll();
              Get.offAllNamed(AppRoutes.LOGIN);
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
            onPressed: () {
              Get.back();
              _storage.clearAll();
              Get.offAllNamed(AppRoutes.LOGIN);
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
