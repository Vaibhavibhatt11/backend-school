import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminProfileController extends GetxController {
  final name = 'Dr. Jonathan Vance';
  final id = 'ADM-9402';
  final yearsService = 12;
  final pendingApprovals = 8;
  final branchName = 'North Hill Campus (Main)';
  final branchCode = 'NHC-772-ADM';
  final location = 'Seattle, WA';
  final emailNotificationsEnabled = true.obs;

  void onUpdatePassword() {
    AppToast.show('Update password screen');
  }

  void onEmailNotificationsToggle() {
    emailNotificationsEnabled.toggle();
    AppToast.show(emailNotificationsEnabled.value ? 'Notifications enabled' : 'Notifications disabled');
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
