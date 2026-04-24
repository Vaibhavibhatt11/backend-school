import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final otpCode = ''.obs;
  final isLoading = false.obs;
  final resendSeconds = 45.obs;
  late String purpose;
  late String identifier;
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    purpose = args['purpose'] ?? 'login';
    identifier = args['identifier'] ?? '';
    startResendTimer();
  }

  void startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 0) {
        timer.cancel();
        return;
      }
      resendSeconds.value--;
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offNamed(
          AppRoutes.RESET_PASSWORD,
          arguments: {'identifier': identifier, 'resetToken': resetToken},
        );
      });
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    resendSeconds.value = 45;
    startResendTimer();
    try {
      await _userRepository.sendOtp(identifier);
      AppToast.show('OTP resent');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}
