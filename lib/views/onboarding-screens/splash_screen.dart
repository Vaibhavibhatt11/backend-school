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
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final sys = Get.find<SystemService>();
      await Future.wait([sys.health(), sys.ready()]);
    } catch (_) {
      // Backend may be unreachable; still allow login / offline UX.
    }
    final session = Get.find<SessionStorageService>();
    final token = await session.getToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Get.offAllNamed(CommonScreenRoutes.loginScreen);
      return;
    }

    final appStorage = AppStorage();
    String? role = appStorage.userRole;
    if (role == null || role.isEmpty) {
      try {
        final auth = Get.find<AuthService>();
        final body = await auth.me();
        final data = extractApiData(body, context: 'me');
        role = AuthUserParse.roleFromData(data) ??
            AuthUserParse.roleFromAuthResponse(body is Map<String, dynamic> ? body : null);
        if (role != null && role.isNotEmpty) {
          appStorage.userRole = role;
        }
      } catch (_) {
        if (!mounted) return;
        Get.offAllNamed(CommonScreenRoutes.loginScreen);
        return;
      }
    }

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
