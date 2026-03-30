import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final otpCode = ''.obs;
  final isLoading = false.obs;
  final resendSeconds = 45.obs;
  late String purpose;
  late String identifier;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    purpose = args['purpose'] ?? 'login';
    identifier = args['identifier'] ?? '';
    startResendTimer();
  }

  void startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
        startResendTimer();
      }
    });
  }

  void updateOtp(String code) {
    otpCode.value = code;
  }

  Future<void> verifyOtp() async {
    if (otpCode.value.length != 6) {
      AppToast.show('Enter 6-digit code');
      return;
    }
    isLoading.value = true;
    try {
      if (purpose == 'login') {
        AppToast.show('OTP login is not enabled. Please sign in with password.');
        return;
      }

      final resetToken = await _userRepository.verifyOtpForReset(
        email: identifier,
        otp: otpCode.value,
      );
      Get.offNamed(
        AppRoutes.RESET_PASSWORD,
        arguments: {'identifier': identifier, 'resetToken': resetToken},
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    resendSeconds.value = 45;
    startResendTimer();
    await _userRepository.sendOtp(identifier);
    AppToast.show('OTP resent');
  }
}
