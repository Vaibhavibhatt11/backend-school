import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/routes/common_routes_screens.dart';
import '../../common/services/session_storage_service.dart';
import '../../common/theme/app_color.dart';
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
    final storage = Get.find<SessionStorageService>();
    final token = await storage.getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(CommonScreenRoutes.mainShell);
    } else {
      Get.offAllNamed(CommonScreenRoutes.loginScreen);
    }
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
