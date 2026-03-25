import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../common/services/auth_service.dart';
import '../../../common/routes/common_routes_screens.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxString email = ''.obs;
  final RxString password = ''.obs;

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  void toggleObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  bool _isValidEmail(String v) {
    final s = v.trim();
    return s.isNotEmpty && s.contains('@') && s.contains('.');
  }

  Future<void> login() async {
    final e = email.value.trim();
    final p = password.value;

    if (!_isValidEmail(e)) {
      Get.snackbar('Login', 'Please enter a valid email address.');
      return;
    }
    if (p.trim().isEmpty) {
      Get.snackbar('Login', 'Please enter your password.');
      return;
    }
    if (p.length < 6) {
      Get.snackbar('Login', 'Password must be at least 6 characters.');
      return;
    }

    try {
      isLoading.value = true;
      await _authService.login(email: e, password: p);

      // After successful login, go to the bottom navigation shell.
      Get.offAllNamed(CommonScreenRoutes.mainShell);
    } on DioException catch (e) {
      String msg;
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        msg = data['message']?.toString() ?? 'Login failed.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        msg = 'Request timed out. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        msg = 'Cannot reach server. Check internet/API URL and try again.';
      } else {
        msg = 'Unable to login. Please try again.';
      }
      Get.snackbar('Login', msg);
    } catch (e) {
      Get.snackbar('Login', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void goToForgotPassword() {
    Get.toNamed(CommonScreenRoutes.forgotPasswordScreen);
  }
}

