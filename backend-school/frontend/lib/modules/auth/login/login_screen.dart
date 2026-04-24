import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/fonts/common_textstyle.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/utils/responsive.dart';
import 'login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.authBackground,
      body: Stack(
        children: [
          Container(
            height: Responsive.hp(context, 0.40),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary,
                  AppColor.primaryDark.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 20),
                  vertical: Responsive.h(context, 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(Responsive.w(context, 12)),
                      decoration: BoxDecoration(
                        color: AppColor.base.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: AppColor.base,
                        size: Responsive.w(context, 28),
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 16)),
                    Text(
                      'School App',
                      style: AppTextStyle.headlineLarge(context).copyWith(
                        color: AppColor.base,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 4)),
                    Text(
                      'Sign in to continue',
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: AppColor.base.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 16),
                Responsive.hp(context, 0.26),
                Responsive.w(context, 16),
                Responsive.h(context, 20),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: AppTextStyle.headlineMedium(context).copyWith(
                            color: AppColor.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          'Login with your email and password',
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.textSecondary,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 20)),
                        Text(
                          'Email',
                          style: AppTextStyle.titleSmall(context).copyWith(
                            color: AppColor.textSecondary,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 8)),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (v) => controller.email.value = v,
                          style: TextStyle(color: AppColor.textPrimary),
                          decoration: _inputDecoration(
                            context,
                            hint: 'you@school.com',
                            prefixIcon: Icons.email_rounded,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 14)),
                        Text(
                          'Password',
                          style: AppTextStyle.titleSmall(context).copyWith(
                            color: AppColor.textSecondary,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 8)),
                        Obx(
                          () => TextField(
                            onChanged: (v) => controller.password.value = v,
                            obscureText: controller.obscurePassword.value,
                            style: TextStyle(color: AppColor.textPrimary),
                            decoration: _inputDecoration(
                              context,
                              hint: 'Enter password',
                              prefixIcon: Icons.lock_rounded,
                              suffixIcon: controller.obscurePassword.value
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              onSuffixTap: controller.toggleObscure,
                            ),
                          ),
                        ),
                        Obx(() {
                          final msg = controller.warningText.value;
                          if (msg.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(top: Responsive.h(context, 8)),
                            child: Text(
                              msg,
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: Responsive.h(context, 6)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: controller.goToForgotPassword,
                            child: Text(
                              'Forgot password?',
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 8)),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: AppColor.base,
                                disabledBackgroundColor:
                                    AppColor.primary.withValues(alpha: 0.35),
                                padding: EdgeInsets.symmetric(
                                  vertical: Responsive.h(context, 15),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    Responsive.w(context, 14),
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColor.base,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: AppTextStyle.titleMedium(context).copyWith(
                                        color: AppColor.base,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textMuted),
      prefixIcon: Icon(prefixIcon, color: AppColor.primary.withValues(alpha: 0.9)),
      suffixIcon: suffixIcon != null
          ? IconButton(
              icon: Icon(suffixIcon, color: AppColor.primary),
              onPressed: onSuffixTap,
            )
          : null,
      filled: true,
      fillColor: AppColor.base,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 12),
        vertical: Responsive.h(context, 12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        borderSide: BorderSide(
          color: AppColor.border.withValues(alpha: 0.9),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        borderSide: BorderSide(
          color: AppColor.border.withValues(alpha: 0.9),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        borderSide: BorderSide(
          color: AppColor.primary,
          width: 1.8,
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 18)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 22)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

