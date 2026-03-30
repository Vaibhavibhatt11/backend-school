import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/app/services/app_storage.dart';
import 'package:erp_frontend/common/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffSettingsView extends StatelessWidget {
  const StaffSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: ListView(
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
          _tile(isDark, Icons.notifications_active_rounded, 'Notification settings'),
          _tile(isDark, Icons.manage_accounts_rounded, 'Account settings'),
          _tile(isDark, Icons.privacy_tip_rounded, 'Privacy control'),
          _tile(isDark, Icons.tune_rounded, 'Other settings'),
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
      ),
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

