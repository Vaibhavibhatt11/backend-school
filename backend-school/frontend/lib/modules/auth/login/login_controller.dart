import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../app/services/app_storage.dart';
import '../../../common/routes/common_routes_screens.dart';
import '../../../common/services/auth_service.dart';
import '../../../common/services/parent/parent_api_utils.dart';
import '../../../common/utils/app_toast.dart';
import '../../../common/utils/auth_route_resolver.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AppStorage _storage = AppStorage();

  final RxString email = ''.obs;
  final RxString password = ''.obs;

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxString warningText = ''.obs;

  void toggleObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  bool _isValidEmail(String v) {
    final s = v.trim();
    return s.isNotEmpty && s.contains('@') && s.contains('.');
  }

  void _setWarning(String message) {
    warningText.value = message;
    AppToast.show(message);
  }

  Future<void> login() async {
    final e = email.value.trim();
    final p = password.value;
    warningText.value = '';

    if (!_isValidEmail(e)) {
      _setWarning('Please enter a valid email address.');
      return;
    }
    if (p.trim().isEmpty) {
      _setWarning('Please enter your password.');
      return;
    }
    if (p.length < 6) {
      _setWarning('Password must be at least 6 characters.');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authService.login(email: e, password: p);

      // Keep GetStorage token in sync with SharedPreferences (legacy + parent flows).
      _storage.token = response.token;
      final user = response.data?['user'];
      String? role;
      if (user is Map && user['role'] != null) {
        role = user['role'].toString();
        _storage.userRole = role;
      }

      AuthRouteResolver.goHomeForRole(role);
    } on DioException catch (e) {
      _setWarning(dioOrApiErrorMessage(e));
    } catch (e) {
      _setWarning(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void goToForgotPassword() {
    Get.toNamed(CommonScreenRoutes.forgotPasswordScreen);
  }
}

