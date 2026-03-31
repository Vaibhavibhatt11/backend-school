import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SafeNavigation {
  SafeNavigation._();

  static void toNamed(
    String route, {
    dynamic arguments,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute == route) return;
      Get.toNamed(route, arguments: arguments);
    });
  }

  static void offNamed(
    String route, {
    dynamic arguments,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute == route) return;
      Get.offNamed(route, arguments: arguments);
    });
  }

  static void offAllNamed(
    String route, {
    dynamic arguments,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute == route) return;
      Get.offAllNamed(route, arguments: arguments);
    });
  }
}
