import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SafeNavigation {
  SafeNavigation._();

  static bool _isEffectivelySameTarget(String route, dynamic arguments) {
    // If caller provides arguments, allow navigation even when route name matches.
    // This is required for tab/feature routes that reuse same page with new args.
    if (arguments != null) return false;
    return Get.currentRoute == route;
  }

  static void toNamed(
    String route, {
    dynamic arguments,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEffectivelySameTarget(route, arguments)) return;
      Get.toNamed(route, arguments: arguments);
    });
  }

  static void offNamed(
    String route, {
    dynamic arguments,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEffectivelySameTarget(route, arguments)) return;
      Get.offNamed(route, arguments: arguments);
    });
  }

  static void offAllNamed(
    String route, {
    dynamic arguments,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEffectivelySameTarget(route, arguments)) return;
      Get.offAllNamed(route, arguments: arguments);
    });
  }
}
