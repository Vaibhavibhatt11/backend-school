import 'package:get/get.dart';
import '../controllers/branch_controller.dart';
import '../controllers/forgot_password_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/reset_password_controller.dart';
import '../controllers/role_controller.dart';
import '../controllers/splash_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
    Get.lazyPut(() => BranchController());
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => OtpController());
    Get.lazyPut(() => ForgotPasswordController());
    Get.lazyPut(() => ResetPasswordController());
    Get.lazyPut(() => RoleController());
  }
}