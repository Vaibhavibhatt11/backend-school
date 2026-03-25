import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Single source for all app colors. Use AppColor everywhere for consistency.
class AppColor {
  AppColor._();

  // Brand
  // Brand (light blue theme)
  static const Color primary = Color(0xFF62B3FF);
  static const Color primaryDark = Color(0xFF0B3A5A);
  static const Color base = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color yellow = Color(0xFFFFC107);
  static Color get border => Get.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF4F4F5);
  static Color get borderLight => Get.isDarkMode ? const Color(0xFF6B7280) : const Color(0xFFA9A9A9);

  // Backgrounds
  static Color get authBackground => Get.isDarkMode ? const Color(0xFF0E1116) : const Color(0xFFF4F4F5);
  static Color get scaffoldBackground => Get.isDarkMode ? const Color(0xFF0B0F14) : const Color(0xFFFFFFFF);
  static Color get cardBackground => Get.isDarkMode ? const Color(0xFF151A22) : const Color(0xFFF4F4F5);
  static Color get cardHighlight => Get.isDarkMode ? const Color(0xFF1B2633) : const Color(0xFFE7F7F6);

  // Text
  static Color get textPrimary => Get.isDarkMode ? const Color(0xFFF3F4F6) : const Color(0xFF1A1A1A);
  static Color get textSecondary => Get.isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280);
  static Color get textMuted => Get.isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);

  // Status
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF005450);
  static const Color warning = Color(0xFFDDB031);
  static const Color info = Color(0xFF0885FE);
  static const Color orange = Color(0xFFFFA500);

  // Token / chip backgrounds
  static const Color tokenYellow = Color(0xFFFFF8E6);
  static const Color tokenBlue = Color(0xFFEDF3FF);
  static const Color tokenGreen = Color(0xFFE7F7F6);
  static const Color tokenRed = Color(0xFFFFF5F4);
  static const Color tokenYellowFont = Color(0xFFDDB031);
  static const Color tokenBlueFont = Color(0xFF0885FE);
  static const Color tokenGreenFont = Color(0xFF005450);
  static const Color tokenRedFont = Color(0xFFCD0000);

  // Legacy aliases (if existing code uses AppColors)
  static const Color primaryColor = primary;
  static const Color baseColor = base;
  static const Color blackColor = black;
  static const Color errorRed = error;
  static Color get alertCardColor => cardBackground;
  static Color get recentProjectCardColor => cardHighlight;
  static Color get employeeCardBgColor => cardBackground;
}
