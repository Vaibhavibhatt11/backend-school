import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_settings_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/app/services/app_storage.dart';
import 'package:erp_frontend/common/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffSettingsView extends GetView<StaffSettingsController> {
  const StaffSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: controller.notificationsEnabled.value,
            onChanged: (v) => controller.updateSettings(notifications: v),
            title: const Text('Notification settings'),
            secondary: const Icon(Icons.notifications_active_rounded),
          ),
          SwitchListTile(
            value: controller.privacyMode.value,
            onChanged: (v) => controller.updateSettings(privacy: v),
            title: const Text('Privacy control'),
            secondary: const Icon(Icons.privacy_tip_rounded),
          ),
          SwitchListTile(
            value: controller.compactView.value,
            onChanged: (v) => controller.updateSettings(compact: v),
            title: const Text('Compact view'),
            secondary: const Icon(Icons.tune_rounded),
          ),
          _tile(isDark, Icons.manage_accounts_rounded, 'Account settings'),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () async {
              if (Get.isRegistered<AuthService>()) {
                await Get.find<AuthService>().logout();
              }
              AppStorage().clearAll();
              Get.offAllNamed(AppRoutes.LOGIN);
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      )),
    );
  }

  Widget _tile(bool isDark, IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

