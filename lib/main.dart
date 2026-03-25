import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/services/theme_service.dart';
import 'common/bindings/controller_bindings.dart';
import 'common/bindings/routes_binding.dart';
import 'common/routes/common_routes_screens.dart';
import 'common/theme/app_color.dart';
import 'modules/main_shell/main_shell_binding.dart';
import 'modules/main_shell/main_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  if (!Get.isRegistered<ThemeService>()) {
    Get.put<ThemeService>(ThemeService(), permanent: true);
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return Obx(
      () => GetMaterialApp(
        initialBinding: ControllerBinding(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColor.scaffoldBackground,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B0F14),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColor.primary,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: themeService.themeMode,
        initialRoute: CommonScreenRoutes.splashScreen,
        getPages: RoutesBinding.routes,
        unknownRoute: GetPage(
          name: '/unknown',
          page: () => const MainShellScreen(),
          binding: MainShellBinding(),
        ),
      ),
    );
  }
}
