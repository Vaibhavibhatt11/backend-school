import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_shell_controller.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_settings_controller.dart';

class AdminSettingsView extends GetView<AdminSettingsController> {
  final bool embedded;
  const AdminSettingsView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = SafeArea(
      child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (embedded && Get.isRegistered<AdminShellController>()) {
                      Get.find<AdminShellController>().setTab(0);
                      return;
                    }
                    if (Get.key.currentState?.canPop() ?? false) {
                      Get.back();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Profile quick card
            InkWell(
              onTap: controller.goToAdminProfile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary,
                      child: Text('SJ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Dr. Sarah Jenkins',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Head of Administration • ID: SCH-2024-01',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Security & Privacy
            const SizedBox(height: 8),
            // App Preferences
            const Text(
              'APP PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.indigo,
                      ),
                    ),
                    title: const Text('Push Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: controller.onPushNotifications,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.translate, color: Colors.blue),
                    ),
                    title: const Text('Language'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('English', style: TextStyle(fontSize: 12)),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: controller.onLanguage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // About
            const Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: controller.onPrivacyPolicy,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: controller.onTerms,
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    title: Text('App Version'),
                    trailing: Text(
                      'v2.4.9 (Build 108)',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Logout
            ElevatedButton.icon(
              onPressed: controller.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: controller.onDeleteAccount,
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              label: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Logged in from San Francisco, US\nLast active: 2 mins ago',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
      ),
    );
    if (embedded) return content;
    return Scaffold(
      body: content,
      bottomNavigationBar: AdminBottomNavBar(currentIndex: 4), // Settings tab
    );
  }
}
