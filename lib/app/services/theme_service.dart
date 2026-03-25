import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_storage.dart';

class ThemeService extends GetxService {
  final _storage = AppStorage();
  final isDarkMode = false.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.isDarkMode;
    ever(isDarkMode, _saveThemeToStorage);
  }

  void _saveThemeToStorage(bool isDark) => _storage.isDarkMode = isDark;

  void toggleTheme() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
