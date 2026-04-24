import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_storage.dart';

class ThemeService extends GetxService {
  final _storage = AppStorage();
  final isDarkMode = false.obs;

  ThemeMode get themeMode => ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = false;
    _saveThemeToStorage(false);
  }

  void _saveThemeToStorage(bool isDark) => _storage.isDarkMode = isDark;

  void toggleTheme() {
    isDarkMode.value = false;
    Get.changeThemeMode(ThemeMode.light);
  }
}
