import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../common/routes/common_routes_screens.dart';
import 'app_toast.dart';

/// Maps backend `user.role` (and legacy enum strings) to the correct home route.
class AuthRouteResolver {
  AuthRouteResolver._();

  /// Navigates to Parent, Teacher, or Admin shell based on [role].
  /// [clearStack] uses [Get.offAllNamed] when true (post-login), [Get.offNamed] when false.
  static void goHomeForRole(
    String? role, {
    bool clearStack = true,
  }) {
    final route = routeForRole(role);
    if (route == null) {
      AppToast.show(
        role == null || role.isEmpty
            ? 'Account role is missing. Please contact support.'
            : 'This app does not support role: $role',
      );
      final go = clearStack ? Get.offAllNamed : Get.offNamed;
      go(CommonScreenRoutes.loginScreen);
      return;
    }
    final go = clearStack ? Get.offAllNamed : Get.offNamed;
    go(route);
  }

  /// Returns a route name, or null if unsupported / missing.
  static String? routeForRole(String? role) {
    if (role == null || role.trim().isEmpty) return null;
    final upper = role.trim().toUpperCase();
    switch (upper) {
      case 'PARENT':
      case 'STUDENT':
        return AppRoutes.PARENT_HOME;
      case 'TEACHER':
      case 'STAFF':
        return AppRoutes.STAFF_HOME;
      case 'SCHOOLADMIN':
      case 'SUPERADMIN':
      case 'HR':
      case 'ACCOUNTANT':
      case 'ADMIN':
      case 'LIBRARIAN':
      case 'TRANSPORT':
      case 'HOSTEL_WARDEN':
      case 'INVENTORY':
        return AppRoutes.ADMIN_HOME;
    }
    final lower = role.trim().toLowerCase();
    switch (lower) {
      case 'parent':
        return AppRoutes.PARENT_HOME;
      case 'teacher':
        return AppRoutes.STAFF_HOME;
      case 'staff':
        return AppRoutes.STAFF_HOME;
      case 'admin':
        return AppRoutes.ADMIN_HOME;
    }
    return null;
  }
}
