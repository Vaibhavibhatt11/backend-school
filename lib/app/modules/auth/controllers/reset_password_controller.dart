import 'package:flutter/widgets.dart';
import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final newPassword = ''.obs;
  final confirmPassword = ''.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;
  final isLoading = false.obs;
  late String identifier;
  late String resetToken;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    identifier = args['identifier'] ?? '';
    resetToken = args['resetToken'] ?? '';
  }

  void toggleNewVisibility() => obscureNew.toggle();
  void toggleConfirmVisibility() => obscureConfirm.toggle();

  double get passwordStrength {
    // Very basic strength calculation
    if (newPassword.value.length >= 8) return 0.65;
    return 0.3;
  }

  String get strengthText {
    if (passwordStrength >= 0.8) return 'Strong';
    if (passwordStrength >= 0.5) return 'Medium';
    return 'Weak';
  }

  bool get hasLength => newPassword.value.length >= 8;
  bool get hasUppercase => newPassword.value.contains(RegExp(r'[A-Z]'));
  bool get hasNumber => newPassword.value.contains(RegExp(r'[0-9]'));
  bool get hasSpecial =>
      newPassword.value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  Future<void> updatePassword() async {
    if (newPassword.value.isEmpty || confirmPassword.value.isEmpty) {
      AppToast.show('Fill all fields');
      return;
    }
    if (newPassword.value != confirmPassword.value) {
      AppToast.show('Passwords do not match');
      return;
    }
    if (resetToken.trim().isEmpty) {
      AppToast.show('Reset token missing. Please request OTP again.');
      return;
    }
    isLoading.value = true;
    try {
      await _userRepository.resetPassword(resetToken, newPassword.value);
      AppToast.show('Password updated');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.LOGIN);
      });
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }
}
