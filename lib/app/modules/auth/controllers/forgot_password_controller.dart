import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final recoveryInfo = ''.obs;
  final isLoading = false.obs;

  Future<void> sendRecovery() async {
    if (recoveryInfo.isEmpty) {
      Get.snackbar('Error', 'Enter email or phone');
      return;
    }
    isLoading.value = true;
    try {
      await _userRepository.sendOtp(recoveryInfo.value);
      // Navigate to OTP with purpose 'forgot'
      Get.toNamed(
        AppRoutes.OTP,
        arguments: {'purpose': 'forgot', 'identifier': recoveryInfo.value},
      );
    } finally {
      isLoading.value = false;
    }
  }
}
