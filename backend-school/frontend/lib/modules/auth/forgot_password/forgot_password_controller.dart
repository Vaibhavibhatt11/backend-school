import 'package:get/get.dart';

import '../../../app/data/repositories/user_repository.dart';
import '../../../common/routes/common_routes_screens.dart';
import '../../../common/utils/app_toast.dart';
import '../../../common/services/parent/parent_api_utils.dart';

class ForgotPasswordController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final RxString email = ''.obs;
  final RxBool isLoading = false.obs;

  bool _isValidEmail(String v) {
    final s = v.trim();
    return s.isNotEmpty && s.contains('@') && s.contains('.');
  }

  Future<void> sendResetLink() async {
    final e = email.value.trim();
    if (!_isValidEmail(e)) {
      AppToast.show('Please enter a valid email address.');
      return;
    }

    isLoading.value = true;
    try {
      await _userRepository.sendOtp(e);
      AppToast.show('Verification code sent. Check your email.');
      Get.offAllNamed(CommonScreenRoutes.loginScreen);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }
}

