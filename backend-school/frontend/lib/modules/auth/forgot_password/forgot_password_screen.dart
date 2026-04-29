import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/fonts/common_textstyle.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/utils/responsive.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackToLogin(),
              SizedBox(height: Responsive.h(context, 14)),
              Text(
                'Reset your password',
                style: AppTextStyle.headlineMedium(context).copyWith(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: Responsive.h(context, 6)),
              Text(
                'Enter your email and we will send you a reset link.',
                style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary),
              ),
              SizedBox(height: Responsive.h(context, 22)),
              _AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: AppTextStyle.titleSmall(context).copyWith(color: AppColor.textSecondary),
                    ),
                    SizedBox(height: Responsive.h(context, 8)),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => controller.email.value = v,
                      style: TextStyle(color: AppColor.textPrimary),
                      decoration: _inputDecoration(
                        context,
                        hint: 'e.g. student@email.com',
                        icon: Icons.email_rounded,
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 16)),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.sendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: AppColor.base,
                            disabledBackgroundColor: AppColor.primary.withValues(alpha: 0.35),
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  height: Responsive.clamp(
                                    context,
                                    18,
                                    min: 16,
                                    max: 22,
                                  ),
                                  width: Responsive.clamp(
                                    context,
                                    18,
                                    min: 16,
                                    max: 22,
                                  ),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColor.base,
                                  ),
                                )
                              : Text(
                                  'Send reset link',
                                  style: AppTextStyle.titleMedium(context).copyWith(
                                    color: AppColor.base,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Back to login',
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textMuted),
      prefixIcon: Icon(icon, color: AppColor.primary.withValues(alpha: 0.9)),
      filled: true,
      fillColor: AppColor.base,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 12),
        vertical: Responsive.h(context, 12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        borderSide: BorderSide(color: AppColor.border.withValues(alpha: 0.9), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        borderSide: BorderSide(color: AppColor.border.withValues(alpha: 0.9), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        borderSide: BorderSide(color: AppColor.primary, width: 1.8),
      ),
    );
  }
}

class _BackToLogin extends StatelessWidget {
  const _BackToLogin();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColor.primary,
            size: Responsive.clamp(context, 24, min: 20, max: 30),
          ),
          tooltip: 'Back',
        ),
        SizedBox(width: Responsive.w(context, 6)),
        Text(
          'Login',
          style: AppTextStyle.titleSmall(context).copyWith(
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

