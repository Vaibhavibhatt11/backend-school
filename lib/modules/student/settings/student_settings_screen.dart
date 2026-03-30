import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/app_toast.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'student_settings_controller.dart';

class StudentSettingsScreen extends GetView<StudentSettingsController> {
  const StudentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(context),
            SizedBox(height: Responsive.h(context, 16)),
            _sectionTitle(context, 'Notifications'),
            Obx(
              () => Column(
                children: [
                  _switchTile(
                    context,
                    title: 'All notifications',
                    subtitle: 'School updates, alerts and messages',
                    icon: Icons.notifications_active_rounded,
                    value: controller.notificationsEnabled.value,
                    onChanged: (v) => controller.notificationsEnabled.value = v,
                  ),
                  SizedBox(height: Responsive.h(context, 8)),
                  _switchTile(
                    context,
                    title: 'Exam reminders',
                    subtitle: 'Remind before upcoming exams',
                    icon: Icons.quiz_rounded,
                    value: controller.examReminderEnabled.value,
                    onChanged: (v) => controller.examReminderEnabled.value = v,
                  ),
                  SizedBox(height: Responsive.h(context, 8)),
                  _switchTile(
                    context,
                    title: 'Homework reminders',
                    subtitle: 'Daily reminder for pending homework',
                    icon: Icons.assignment_turned_in_rounded,
                    value: controller.homeworkReminderEnabled.value,
                    onChanged: (v) => controller.homeworkReminderEnabled.value = v,
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 14)),
            _sectionTitle(context, 'Security & Preferences'),
            Obx(
              () => Column(
                children: [
                  _switchTile(
                    context,
                    title: 'Biometric lock',
                    subtitle: 'Use fingerprint/face unlock (demo)',
                    icon: Icons.fingerprint_rounded,
                    value: controller.biometricEnabled.value,
                    onChanged: (v) => controller.biometricEnabled.value = v,
                  ),
                  SizedBox(height: Responsive.h(context, 8)),
                  _menuTile(
                    context,
                    title: 'Language',
                    subtitle: controller.language.value,
                    icon: Icons.language_rounded,
                    onTap: () => _showLanguageSelector(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 14)),
            _sectionTitle(context, 'Legal & Privacy'),
            _menuTile(
              context,
              title: 'Privacy Policy',
              subtitle: 'How we use and protect your data',
              icon: Icons.privacy_tip_rounded,
              onTap: () => _showLegalSheet(
                context,
                title: 'Privacy Policy',
                content:
                    'We collect only required student data to provide school services. Data is securely stored and used for attendance, homework, communication, and academic tracking. We do not sell personal data to third parties.',
              ),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            _menuTile(
              context,
              title: 'Terms & Conditions',
              subtitle: 'Rules for using this app',
              icon: Icons.gavel_rounded,
              onTap: () => _showLegalSheet(
                context,
                title: 'Terms & Conditions',
                content:
                    'By using this app, users agree to provide accurate information and use features responsibly. School administration may update features and policies at any time. Misuse of communication tools may lead to access restrictions.',
              ),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            _menuTile(
              context,
              title: 'Help & Support',
              subtitle: 'Contact school support team',
              icon: Icons.support_agent_rounded,
              onTap: () => AppToast.show('Please contact: support@schoolapp.com'),
            ),
            SizedBox(height: Responsive.h(context, 14)),
            _sectionTitle(context, 'Account'),
            _dangerActionTile(
              context,
              title: 'Logout',
              subtitle: 'Sign out from this device',
              icon: Icons.logout_rounded,
              onTap: () => _confirmLogout(context),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            _dangerActionTile(
              context,
              title: 'Delete account',
              subtitle: 'Remove account access from this device',
              icon: Icons.delete_forever_rounded,
              onTap: () => _confirmDeleteAccount(context),
            ),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primaryDark.withValues(alpha: 0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 10)),
            decoration: BoxDecoration(
              color: AppColor.base.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            ),
            child: Icon(Icons.settings_suggest_rounded, color: AppColor.base, size: Responsive.w(context, 24)),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App settings',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    color: AppColor.base,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  'Manage privacy and preferences',
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColor.base.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
      child: Text(
        title,
        style: AppTextStyle.titleSmall(context).copyWith(
          color: AppColor.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 12),
        vertical: Responsive.h(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 8)),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColor.primary, size: Responsive.w(context, 20)),
          ),
          SizedBox(width: Responsive.w(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: Responsive.h(context, 2)),
                Text(
                  subtitle,
                  style: AppTextStyle.caption(context).copyWith(color: AppColor.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColor.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColor.primary,
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 12),
            vertical: Responsive.h(context, 12),
          ),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(context, 8)),
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColor.primary, size: Responsive.w(context, 20)),
              ),
              SizedBox(width: Responsive.w(context, 10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: Responsive.h(context, 2)),
                    Text(
                      subtitle,
                      style: AppTextStyle.caption(context).copyWith(color: AppColor.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dangerActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 12),
            vertical: Responsive.h(context, 12),
          ),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            border: Border.all(color: AppColor.error.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(context, 8)),
                decoration: BoxDecoration(
                  color: AppColor.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColor.error, size: Responsive.w(context, 20)),
              ),
              SizedBox(width: Responsive.w(context, 10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColor.error,
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 2)),
                    Text(
                      subtitle,
                      style: AppTextStyle.caption(context).copyWith(color: AppColor.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final options = ['English', 'Hindi', 'Gujarati'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.base,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(context, 18))),
      ),
      builder: (ctx) => SafeArea(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((lang) {
              final selected = controller.language.value == lang;
              return ListTile(
                onTap: () {
                  controller.language.value = lang;
                  Navigator.of(ctx).pop();
                },
                leading: Icon(
                  selected ? Icons.check_circle_rounded : Icons.language_rounded,
                  color: selected ? AppColor.primary : AppColor.textMuted,
                ),
                title: Text(lang, style: AppTextStyle.bodyMedium(ctx)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLegalSheet(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.75,
        ),
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(ctx, 22))),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(ctx, 16),
            Responsive.h(ctx, 16),
            Responsive.w(ctx, 16),
            MediaQuery.of(ctx).padding.bottom + Responsive.h(ctx, 16),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.titleLarge(ctx).copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: Responsive.h(ctx, 10)),
                Text(
                  content,
                  style: AppTextStyle.bodyMedium(ctx).copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This will remove your account session from this device. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteAccount();
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
