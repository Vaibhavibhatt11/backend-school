import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'Settings', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            controller.userName.value.isNotEmpty
                                ? controller.userName.value
                                      .trim()
                                      .split(RegExp(r'\s+'))
                                      .take(2)
                                      .map(
                                        (p) =>
                                            p.isEmpty ? '' : p[0].toUpperCase(),
                                      )
                                      .join()
                                : 'PU',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.userName.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${controller.userRole.value} • ID: ${controller.userId.value}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Account & Security
            const Text(
              'ACCOUNT & SECURITY',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              icon: Icons.person,
              iconColor: Colors.blue,
              label: 'Account Settings',
              onTap: controller.goToPersonalInfo,
            ),
            _buildSettingsItem(
              icon: Icons.lock,
              iconColor: Colors.green,
              label: 'Password & Security',
              onTap: controller.goToPasswordSecurity,
            ),
            const SizedBox(height: 24),
            // Notification preferences
            const Text(
              'NOTIFICATION PREFERENCES',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _buildSettingsItem(
                icon: Icons.notifications_active_outlined,
                iconColor: Colors.orange,
                label: 'Push Notifications',
                trailing: Switch(
                  value: controller.pushNotificationsEnabled.value,
                  onChanged: controller.togglePushNotifications,
                ),
                onTap: () => controller.togglePushNotifications(
                  !controller.pushNotificationsEnabled.value,
                ),
              ),
            ),
            Obx(
              () => _buildSettingsItem(
                icon: Icons.email_outlined,
                iconColor: Colors.indigo,
                label: 'Email Notifications',
                trailing: Switch(
                  value: controller.emailNotificationsEnabled.value,
                  onChanged: controller.toggleEmailNotifications,
                ),
                onTap: () => controller.toggleEmailNotifications(
                  !controller.emailNotificationsEnabled.value,
                ),
              ),
            ),
            Obx(
              () => _buildSettingsItem(
                icon: Icons.sms_outlined,
                iconColor: Colors.teal,
                label: 'SMS Notifications',
                trailing: Switch(
                  value: controller.smsNotificationsEnabled.value,
                  onChanged: controller.toggleSmsNotifications,
                ),
                onTap: () => controller.toggleSmsNotifications(
                  !controller.smsNotificationsEnabled.value,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Privacy controls
            const Text(
              'PRIVACY CONTROLS',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _buildSettingsItem(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.purple,
                label: 'Private Profile Visibility',
                trailing: Switch(
                  value: controller.profileVisibilityPrivate.value,
                  onChanged: controller.toggleProfilePrivacy,
                ),
                onTap: () => controller.toggleProfilePrivacy(
                  !controller.profileVisibilityPrivate.value,
                ),
              ),
            ),
            Obx(
              () => _buildSettingsItem(
                icon: Icons.insights_outlined,
                iconColor: Colors.brown,
                label: 'Allow Analytics Sharing',
                trailing: Switch(
                  value: controller.analyticsSharingEnabled.value,
                  onChanged: controller.toggleAnalyticsSharing,
                ),
                onTap: () => controller.toggleAnalyticsSharing(
                  !controller.analyticsSharingEnabled.value,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Language settings
            const Text(
              'LANGUAGE SETTINGS',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedLanguage.value,
                  items: controller.languageOptions
                      .map(
                        (lang) => DropdownMenuItem<String>(
                          value: lang,
                          child: Text(lang),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.updateLanguage(v);
                  },
                  decoration: const InputDecoration(
                    labelText: 'App Language',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Help & Support
            const Text(
              'HELP & SUPPORT',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              icon: Icons.help_outline,
              iconColor: Colors.red,
              label: 'Help Center',
              onTap: controller.goToHelpCenter,
            ),
            _buildSettingsItem(
              icon: Icons.description,
              iconColor: Colors.grey,
              label: 'Privacy Policy',
              onTap: controller.goToPrivacyPolicy,
            ),
            const SizedBox(height: 24),
            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Log Out'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmDeleteAccount,
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                ),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'Parent Module',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Live API Connected',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(currentIndex: 4), // Profile
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will remove your account session from this device. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(label),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      tileColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

}
