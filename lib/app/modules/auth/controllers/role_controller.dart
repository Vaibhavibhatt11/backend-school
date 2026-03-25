import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../services/app_storage.dart';

class RoleController extends GetxController {
  final _storage = AppStorage();

  void selectRole(UserRole role) {
    _storage.userRole = role.toString().split('.').last; // store role string
    switch (role) {
      case UserRole.parent:
        Get.offNamed(AppRoutes.PARENT_HOME);
        break;
      case UserRole.teacher:
        Get.offNamed(AppRoutes.TEACHER_HOME);
        break;
      case UserRole.admin:
        Get.offNamed(AppRoutes.ADMIN_HOME);
        break;
    }
  }
}
