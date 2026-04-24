import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../utils/responsive.dart';

class AppTextStyle {
  AppTextStyle._();

  static TextStyle headlineLarge(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 22),
        fontWeight: FontWeight.w700,
        color: AppColor.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 18),
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle headlineSmall(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 16),
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 16),
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle titleSmall(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 12),
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 16),
        fontWeight: FontWeight.w400,
        color: AppColor.textPrimary,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w400,
        color: AppColor.textPrimary,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 12),
        fontWeight: FontWeight.w400,
        color: AppColor.textSecondary,
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 12),
        fontWeight: FontWeight.w500,
        color: AppColor.textSecondary,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: Responsive.sp(context, 11),
        fontWeight: FontWeight.w400,
        color: AppColor.textMuted,
      );
}
