import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/services/app_storage.dart';
import '../../common/routes/common_routes_screens.dart';
import '../../common/services/auth_service.dart';
import '../../common/services/parent/parent_api_utils.dart';
import '../../common/services/system_service.dart';
import '../../common/services/session_storage_service.dart';
import '../../common/theme/app_color.dart';
import '../../common/utils/auth_route_resolver.dart';
import '../../common/utils/auth_user_parse.dart';
import '../../common/utils/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _safeOffAllNamed(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Get.currentRoute != route) {
        Get.offAllNamed(route);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _boot();
  }

  void _warmBackendChecks() {
    final sys = Get.find<SystemService>();
    unawaited(sys.health().catchError((_) {}));
    unawaited(sys.ready().catchError((_) {}));
  }

  Future<String?> _resolveRoleFast(SessionStorageService session) async {
    final appStorage = AppStorage();
    final storedRole = appStorage.userRole;
    if (storedRole != null && storedRole.isNotEmpty) return storedRole;

    // Fast local path: parse previously saved auth response.
    final cachedLogin = await session.getLoginResponse();
    final cachedRole = AuthUserParse.roleFromAuthResponse(cachedLogin);
    if (cachedRole != null && cachedRole.isNotEmpty) {
      appStorage.userRole = cachedRole;
      return cachedRole;
    }

    // Fallback path: single lightweight /auth/me probe with timeout.
    try {
      final auth = Get.find<AuthService>();
      final body = await auth
          .me()
          .timeout(const Duration(milliseconds: 1500));
      final data = extractApiData(body, context: 'me');
      final role = AuthUserParse.roleFromData(data) ??
          AuthUserParse.roleFromAuthResponse(body);
      if (role != null && role.isNotEmpty) {
        appStorage.userRole = role;
      }
      return role;
    } catch (_) {
      return null;
    }
  }

  Future<void> _boot() async {
    // Do not block app start on backend probes.
    _warmBackendChecks();
    final session = Get.find<SessionStorageService>();
    final token = await session.getToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _safeOffAllNamed(CommonScreenRoutes.loginScreen);
      return;
    }

    final role = await _resolveRoleFast(session);

    if (!mounted) return;
    AuthRouteResolver.goHomeForRole(role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: Responsive.w(context, 80),
              color: AppColor.base,
            ),
            SizedBox(height: Responsive.h(context, 16)),
            Text(
              'School App',
              style: TextStyle(
                fontSize: Responsive.sp(context, 24),
                fontWeight: FontWeight.w700,
                color: AppColor.base,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
