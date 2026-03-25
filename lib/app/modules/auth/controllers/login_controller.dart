import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../services/app_storage.dart';

class LoginController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
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
      // Step 1: Validate credentials and request OTP
      final success = await _userRepository.requestLoginOtp(
        emailOrPhone.value,
        password.value,
      );
      if (success) {
        // Navigate to OTP screen with purpose='login' and identifier
        Get.toNamed(
          AppRoutes.OTP,
          arguments: {'purpose': 'login', 'identifier': emailOrPhone.value},
        );
      } else {
        Get.snackbar('Error', 'Invalid credentials');
      }
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
