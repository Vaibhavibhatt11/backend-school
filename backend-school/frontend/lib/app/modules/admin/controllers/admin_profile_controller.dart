import 'package:erp_frontend/app/services/app_storage.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/auth_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/routes/common_routes_screens.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminProfileController extends GetxController {
  AdminProfileController(this._adminService);

  final AdminService _adminService;
  final isLoading = false.obs;
  final name = 'Admin'.obs;
  final id = '-'.obs;
  final yearsService = 0.obs;
  final pendingApprovals = 0.obs;
  final branchName = '-'.obs;
  final branchCode = '-'.obs;
  final location = '-'.obs;
  final emailNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final profileData = await _adminService.getProfileMe();
      final schoolData = await _adminService.getSchoolProfile();
      final pendingData = await _adminService.getPendingApprovalsSummary();
      try {
        final settingsData = await _adminService.getSchoolSettings();
        final settings =
            settingsData['settings'] as Map<String, dynamic>? ?? const {};
        final emailPref =
            settings['emailNotificationsEnabled'] ??
            settings['emailNotifications'];
        if (emailPref is bool) {
          emailNotificationsEnabled.value = emailPref;
        }
      } catch (_) {}

      final profile =
          profileData['profile'] as Map<String, dynamic>? ?? const {};
      final school = schoolData['profile'] as Map<String, dynamic>? ?? const {};
      name.value = profile['fullName']?.toString() ?? 'Admin';
      id.value = profile['id']?.toString() ?? '-';
      branchName.value = school['name']?.toString() ?? '-';
      branchCode.value = school['code']?.toString() ?? '-';
      location.value = school['timezone']?.toString() ?? '-';
      pendingApprovals.value =
          (pendingData['totalPending'] as num?)?.toInt() ?? 0;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void onUpdatePassword() {
    loadProfile();
  }

  Future<void> onEmailNotificationsToggle(bool value) async {
    emailNotificationsEnabled.value = value;
    await loadProfile();
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
              AppStorage().clearAll();
              Get.offAllNamed(CommonScreenRoutes.loginScreen);
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
