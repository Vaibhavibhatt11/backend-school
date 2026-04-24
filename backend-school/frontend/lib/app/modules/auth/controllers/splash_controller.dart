import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  void goToNext() {
    Get.offNamed(AppRoutes.BRANCH_SELECTION);
  }
}
// import 'package:erp_frontend/app/routes/app_pages.dart';
// import 'package:get/get.dart';
// import '../../../services/app_storage.dart';

// class SplashController extends GetxController {
//   final _storage = AppStorage();

//   @override
//   void onInit() {
//     super.onInit();
//     _checkAuth();
//   }

//   void _checkAuth() async {
//     await Future.delayed(const Duration(seconds: 2)); // simulate splash
//     final token = _storage.token;
//     final role = _storage.userRole;
//     if (token != null && role != null) {
//       // Navigate to appropriate dashboard
//       switch (role) {
//         case 'parent':
//           Get.offNamed(AppRoutes.PARENT_DASHBOARD);
//           break;
//         case 'teacher':
//           Get.offNamed(AppRoutes.TEACHER_DASHBOARD);
//           break;
//         case 'admin':
//           Get.offNamed(AppRoutes.ADMIN_DASHBOARD);
//           break;
//         default:
//           Get.offNamed(AppRoutes.BRANCH_SELECTION);
//       }
//     } else {
//       Get.offNamed(AppRoutes.BRANCH_SELECTION);
//     }
//   }
// }
