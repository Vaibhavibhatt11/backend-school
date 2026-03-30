import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:erp_frontend/common/utils/auth_route_resolver.dart';
import 'package:get/get.dart';
import '../../../../common/services/auth_service.dart';
import '../../../../common/utils/auth_user_parse.dart';
import '../../../services/app_storage.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final _storage = AppStorage();

  final emailOrPhone = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> signIn() async {
    if (emailOrPhone.isEmpty || password.isEmpty) {
      AppToast.show('Please fill all fields');
      return;
    }
    final email = emailOrPhone.value.trim();
    final pass = password.value;
    isLoading.value = true;
    try {
      final response = await _authService.login(
        email: email,
        password: pass,
      );

      // Keep GetStorage in sync with SharedPreferences token for legacy flows.
      _storage.token = response.token;

      String? role = AuthUserParse.roleFromData(response.data);
      role ??= AuthUserParse.roleFromAuthResponse(response.raw);
      if (role != null && role.isNotEmpty) {
        _storage.userRole = role;
      }

      AuthRouteResolver.goHomeForRole(role);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void goToOtp() {
    // For cases where user wants OTP directly (if needed)
    Get.toNamed(
      AppRoutes.OTP,
      arguments: {'purpose': 'login', 'identifier': emailOrPhone.value},
    );
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.FORGOT_PASSWORD);
  }
}
