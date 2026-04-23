import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reset Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create New Password',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your new password must be different from previous used passwords to ensure account security.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),
            // New Password
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'New Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => CustomTextField(
                hint: '••••••••',
                obscureText: controller.obscureNew.value,
                onChanged: (val) => controller.newPassword.value = val,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureNew.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.toggleNewVisibility,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Strength indicator
            Obx(
              () => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password Strength: ${controller.strengthText}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${(controller.passwordStrength * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: controller.passwordStrength,
                    backgroundColor:
                        isDark ? AppColors.borderDark : Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    children: [
                      _buildCheckItem(
                        '8+ Characters',
                        controller.hasLength,
                        isDark,
                      ),
                      _buildCheckItem(
                        'One Uppercase',
                        controller.hasUppercase,
                        isDark,
                      ),
                      _buildCheckItem(
                        'One Number',
                        controller.hasNumber,
                        isDark,
                      ),
                      _buildCheckItem(
                        'Special Char',
                        controller.hasSpecial,
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Confirm Password
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Confirm New Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => CustomTextField(
                hint: '••••••••',
                obscureText: controller.obscureConfirm.value,
                onChanged: (val) => controller.confirmPassword.value = val,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureConfirm.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.toggleConfirmVisibility,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => CustomButton(
                text: 'Update Password',
                onPressed:
                    controller.isLoading.value
                        ? null
                        : controller.updatePassword,
                isLoading: controller.isLoading.value,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Contact Support',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text, bool isChecked, bool isDark) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color:
              isChecked
                  ? AppColors.primary
                  : (isDark ? AppColors.textSecondaryDark : Colors.grey),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color:
                isChecked
                    ? (isDark ? AppColors.textDark : AppColors.textLight)
                    : (isDark ? AppColors.textSecondaryDark : Colors.grey),
          ),
        ),
      ],
    );
  }
}
