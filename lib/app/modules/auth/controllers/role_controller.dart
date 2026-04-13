import 'package:flutter/widgets.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/routes/common_routes_screens.dart';
import 'package:erp_frontend/common/services/auth_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:erp_frontend/common/utils/auth_route_resolver.dart';
import 'package:erp_frontend/common/utils/auth_user_parse.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';

class RoleController extends GetxController {
  void _safeOffNamed(String route, {bool clearStack = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute == route) return;
      if (clearStack) {
        Get.offAllNamed(route);
      } else {
        Get.offNamed(route);
      }
    });
  }

  Future<void> selectRole(UserRole role) async {
    try {
      final auth = Get.find<AuthService>();
      final body = await auth.me();
      final data = extractApiData(body, context: 'me');
      final backendRole = AuthUserParse.roleFromData(data) ??
          AuthUserParse.roleFromAuthResponse(body);
      if (backendRole != null && backendRole.isNotEmpty) {
        if (!_backendAllowsUiRole(backendRole, role)) {
          AppToast.show(
            'This account is $backendRole. Opening the correct portal.',
          );
          AuthRouteResolver.goHomeForRole(backendRole, clearStack: true);
          return;
        }
      }
    } catch (_) {
      AppToast.show('Session expired. Please sign in again.');
      _safeOffNamed(CommonScreenRoutes.loginScreen, clearStack: true);
      return;
    }

    switch (role) {
      case UserRole.parent:
        _safeOffNamed(AppRoutes.PARENT_HOME);
        break;
      case UserRole.teacher:
        // Live staff APIs use `StaffShellView` (same as post-login routing).
        _safeOffNamed(AppRoutes.STAFF_HOME);
        break;
      case UserRole.admin:
        _safeOffNamed(AppRoutes.ADMIN_HOME);
        break;
    }
  }

  static bool _backendAllowsUiRole(String backend, UserRole picked) {
    final u = backend.trim().toUpperCase();
    switch (picked) {
      case UserRole.parent:
        return u == 'PARENT' || u == 'STUDENT';
      case UserRole.teacher:
        return u == 'TEACHER' || u == 'STAFF';
      case UserRole.admin:
        return u == 'SCHOOLADMIN' ||
            u == 'SUPERADMIN' ||
            u == 'HR' ||
            u == 'ACCOUNTANT' ||
            u == 'ADMIN';
    }
  }
}
