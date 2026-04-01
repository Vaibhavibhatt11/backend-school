import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SafeNavigation {
  SafeNavigation._();

  static String? _queuedNavigationKey;

  static bool _isEffectivelySameTarget(String route, dynamic arguments) {
    if (arguments != null) return false;
    return Get.currentRoute == route;
  }

  static void _runNavigation(
    String route,
    dynamic arguments,
    VoidCallback action,
  ) {
    if (_isEffectivelySameTarget(route, arguments)) return;
    action();
  }

  static void _scheduleNavigation(
    String route,
    dynamic arguments,
    VoidCallback action,
  ) {
    final key = '$route|${arguments.hashCode}';
    final phase = SchedulerBinding.instance.schedulerPhase;

    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      _runNavigation(route, arguments, action);
      return;
    }

    if (_queuedNavigationKey == key) return;
    _queuedNavigationKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_queuedNavigationKey != key) return;
      _queuedNavigationKey = null;
      _runNavigation(route, arguments, action);
    });
  }

  static void toNamed(String route, {dynamic arguments}) {
    _scheduleNavigation(
      route,
      arguments,
      () => Get.toNamed(route, arguments: arguments),
    );
  }

  static void offNamed(String route, {dynamic arguments}) {
    _scheduleNavigation(
      route,
      arguments,
      () => Get.offNamed(route, arguments: arguments),
    );
  }

  static void offAllNamed(String route, {dynamic arguments}) {
    _scheduleNavigation(
      route,
      arguments,
      () => Get.offAllNamed(route, arguments: arguments),
    );
  }
}
