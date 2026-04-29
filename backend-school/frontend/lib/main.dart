import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/services/theme_service.dart';
import 'app/routes/app_pages.dart';
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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: ControllerBinding(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.scaffoldBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
      ),
      themeMode: ThemeMode.light,
      initialRoute: CommonScreenRoutes.splashScreen,
      getPages: [
        ...RoutesBinding.routes,
        ...AppPages.routes,
      ],
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => const MainShellScreen(),
        binding: MainShellBinding(),
      ),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final mediaQuery = MediaQuery.of(context);
        final textScale = mediaQuery.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: textScale),
          child: child,
        );
      },
    );
  }
}
