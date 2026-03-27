import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
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

  @override
  void onInit() {
    super.onInit();
    identifier = Get.arguments['identifier'] ?? '';
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
    isLoading.value = true;
    try {
      // Dummy: assume we pass the email/phone from previous screen
      await _userRepository.resetPassword('dummy@email.com', newPassword.value);
      AppToast.show('Password updated');
      Get.offAllNamed(AppRoutes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }
}
