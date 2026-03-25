import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/app/services/theme_service.dart';
import 'package:get/get.dart';

class TeacherProfileController extends GetxController {
  final themeService = Get.find<ThemeService>();

  void logout() {
    // Clear storage and navigate to login
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void navigateToSettings() {
    // Navigate to settings screen (could be within profile)
  }
}
