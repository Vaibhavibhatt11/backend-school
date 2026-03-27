import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/app/services/app_storage.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/auth_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
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

  Map<String, dynamic> _schoolSettings = {};

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
        final settings = settingsData['settings'] as Map<String, dynamic>? ?? const {};
        _schoolSettings = Map<String, dynamic>.from(settings);
        final emailPref = settings['emailNotificationsEnabled'] ?? settings['emailNotifications'];
        if (emailPref is bool) {
          emailNotificationsEnabled.value = emailPref;
        }
      } catch (_) {
        _schoolSettings = {};
      }

      final profile = profileData['profile'] as Map<String, dynamic>? ?? const {};
      final school = schoolData['profile'] as Map<String, dynamic>? ?? const {};
      name.value = profile['fullName']?.toString() ?? 'Admin';
      id.value = profile['id']?.toString() ?? '-';
      branchName.value = school['name']?.toString() ?? '-';
      branchCode.value = school['code']?.toString() ?? '-';
      location.value = school['timezone']?.toString() ?? '-';
      pendingApprovals.value = (pendingData['totalPending'] as num?)?.toInt() ?? 0;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void onUpdatePassword() {
    AppToast.show('Update password screen');
  }

  Future<void> onEmailNotificationsToggle(bool value) async {
    _schoolSettings['emailNotificationsEnabled'] = value;
    try {
      await _adminService.patchSchoolSettings({'settings': _schoolSettings});
      emailNotificationsEnabled.value = value;
    } catch (_) {
      try {
        await _adminService.updateSchoolSettings({'settings': _schoolSettings});
        emailNotificationsEnabled.value = value;
      } catch (e) {
        AppToast.show(dioOrApiErrorMessage(e));
      }
    }
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
              Get.offAllNamed(AppRoutes.LOGIN);
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
