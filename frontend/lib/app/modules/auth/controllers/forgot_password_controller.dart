import 'package:flutter/widgets.dart';
import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final recoveryInfo = ''.obs;
  final isLoading = false.obs;

  Future<void> sendRecovery() async {
    final value = recoveryInfo.value.trim();
    if (value.isEmpty) {
      AppToast.show('Enter email');
      return;
    }
    if (!value.contains('@')) {
      AppToast.show('Enter a valid email address');
      return;
    }
    isLoading.value = true;
    try {
      await _userRepository.sendOtp(value);
      // Navigate to OTP with purpose 'forgot'
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(
          AppRoutes.OTP,
          arguments: {'purpose': 'forgot', 'identifier': value},
        );
      });
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }
}
