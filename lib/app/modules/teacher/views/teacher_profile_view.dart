import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/navbar/teacher_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_profile_controller.dart';

class TeacherProfileView extends GetView<TeacherProfileController> {
  const TeacherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),
                // Profile image
                Center(
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        child: Icon(Icons.person, size: 42),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Sarah Jenkins',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const Center(
                  child: Text(
                    'Senior Educator',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EMP-2024-089',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Designated Subjects
                _buildSectionTitle('Designated Subjects'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSubjectChip('Advanced Mathematics'),
                    _buildSubjectChip('Quantum Physics'),
                    _buildSubjectChip('Statistics'),
                  ],
                ),
                const SizedBox(height: 24),
                // School Information
                _buildSectionTitle('School Information'),
                const SizedBox(height: 8),
                _buildInfoTile(
                  icon: Icons.school,
                  title: 'St. Xavier’s High School',
                  subtitle: 'Main Campus, Block A',
                ),
                _buildInfoTile(
                  icon: Icons.account_tree,
                  title: 'Science Department',
                  subtitle: 'Secondary Education Wing',
                ),
                const SizedBox(height: 24),
                // App Settings
                _buildSectionTitle('App Settings'),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  icon: Icons.notifications_active,
                  title: 'Notification Preferences',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.security,
                  title: 'Security & Privacy',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.translate,
                  title: 'Language',
                  trailing: Text(
                    'English',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                // Logout button
                OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Version 2.4.12 (Build 450)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildSubjectChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.primary)),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
