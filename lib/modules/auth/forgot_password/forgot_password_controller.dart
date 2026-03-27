import 'package:get/get.dart';

import '../../../common/routes/common_routes_screens.dart';
import '../../../common/utils/app_toast.dart';

class ForgotPasswordController extends GetxController {
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
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;

    AppToast.show('Reset link would be sent to your email (demo).');
    Get.offAllNamed(CommonScreenRoutes.loginScreen);
  }
}

