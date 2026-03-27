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
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/60',
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
              label: 'Personal Information',
              onTap: controller.goToPersonalInfo,
            ),
            _buildSettingsItem(
              icon: Icons.lock,
              iconColor: Colors.green,
              label: 'Password & Security',
              onTap: controller.goToPasswordSecurity,
            ),
            _buildSwitchItem(
              icon: Icons.fingerprint,
              iconColor: Colors.purple,
              label: 'Use FaceID Login',
              value: controller.faceIdEnabled.value,
              onChanged: controller.toggleFaceId,
            ),
            const SizedBox(height: 24),
            // Preferences
            const Text(
              'PREFERENCES',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildSwitchItem(
              icon: Icons.notifications,
              iconColor: Colors.amber,
              label: 'Push Notifications',
              value: controller.pushNotificationsEnabled.value,
              onChanged: controller.togglePushNotifications,
            ),
            _buildSettingsItem(
              icon: Icons.language,
              iconColor: Colors.indigo,
              label: 'Language',
              trailing: Obx(() => Text(controller.selectedLanguage.value)),
              onTap: () {},
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
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
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
                children: const [
                  Text(
                    'EduConnect Pro v2.4.0',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Made with care for Education',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
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
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
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
          color: iconColor.withOpacity(0.1),
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

  Widget _buildSwitchItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label)),
          Obx(() {
            bool currentValue;
            if (label == 'Use FaceID Login') {
              currentValue = controller.faceIdEnabled.value;
            } else {
              currentValue = controller.pushNotificationsEnabled.value;
            }
            return Switch(
              value: currentValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            );
          }),
        ],
      ),
    );
  }

}
