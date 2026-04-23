import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const CustomAppBar(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Step 1 of 2',
                      style: TextStyle(
                        color:
                            isDark ? AppColors.textSecondaryDark : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Enter your registered email address. We\'ll send you a secure link to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 32),
                // Recovery info label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RECOVERY INFO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Input field
                CustomTextField(
                  hint: 'Email address',
                  onChanged: (val) => controller.recoveryInfo.value = val,
                  prefixIcon: const Icon(Icons.alternate_email),
                ),
                const SizedBox(height: 24),
                // Continue button
                Obx(
                  () => CustomButton(
                    text: 'Continue',
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : controller.sendRecovery,
                    isLoading: controller.isLoading.value,
                    icon: Icons.arrow_forward,
                  ),
                ),
                const SizedBox(height: 16),
                // OR recover via
                Text(
                  'OR RECOVER VIA',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.sms, color: AppColors.primary),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.surfaceDark : Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.qr_code_2,
                        color: AppColors.primary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.surfaceDark : Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Need help?
                Text(
                  'Need help?',
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Contact School Admin',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Home indicator
                Container(
                  width: 120,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
