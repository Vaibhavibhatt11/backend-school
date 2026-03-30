import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Sign In'),
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.school, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'School Ecosystem',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Access your school account with your credentials.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Email or Phone Number',
              hint: 'e.g. user@school.edu',
              onChanged: (val) => controller.emailOrPhone.value = val,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 16),
            Obx(
              () => CustomTextField(
                label: 'Password',
                hint: 'Enter your password',
                obscureText: controller.obscurePassword.value,
                onChanged: (val) => controller.password.value = val,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.goToForgotPassword,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => CustomButton(
                text: 'Sign In',
                onPressed:
                    controller.isLoading.value ? null : controller.signIn,
                isLoading: controller.isLoading.value,
                icon: Icons.login,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR CONTINUE WITH',
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Sign in with Google',
              onPressed: () {},
              isOutlined: true,
              icon: Icons.g_mobiledata,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.goToOtp,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sms, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Log in with OTP instead',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Having trouble logging in?',
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
                'Contact School Administration',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'TERMS',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'PRIVACY',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
