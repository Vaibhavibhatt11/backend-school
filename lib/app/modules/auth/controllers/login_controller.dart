import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../common/services/auth_service.dart';
import '../../../services/app_storage.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final _storage = AppStorage();

  final emailOrPhone = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> signIn() async {
    if (emailOrPhone.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _authService.login(
        email: emailOrPhone.value,
        password: password.value,
      );

      // Keep GetStorage in sync with SharedPreferences token for legacy flows.
      _storage.token = response.token;

      final user = response.data?['user'];
      if (user is Map && user['role'] != null) {
        _storage.userRole = user['role'].toString();
      }

      Get.offNamed(AppRoutes.ROLE_SELECTION);
    } catch (e) {
      Get.snackbar('Login Failed', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void goToOtp() {
    // For cases where user wants OTP directly (if needed)
    Get.toNamed(
      AppRoutes.OTP,
      arguments: {'purpose': 'login', 'identifier': emailOrPhone.value},
    );
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.FORGOT_PASSWORD);
  }
}
