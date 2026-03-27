// import 'package:erp_frontend/app/data/repositories/user_repository.dart';
// import 'package:erp_frontend/app/routes/app_pages.dart';
// import 'package:get/get.dart';
// import '../../../services/app_storage.dart';

// class OtpController extends GetxController {
//   final UserRepository _userRepository = Get.find<UserRepository>();
//   final _storage = AppStorage();

//   final otpCode = ''.obs;
//   final isLoading = false.obs;
//   final resendSeconds = 45.obs;
//   late String purpose;
//   late String identifier; // email/phone

//   @override
//   void onInit() {
//     super.onInit();
//     final args = Get.arguments;
//     purpose = args['purpose'] ?? 'login';
//     identifier = args['identifier'] ?? '';
//     startResendTimer();
//   }

//   void startResendTimer() {
//     Future.delayed(const Duration(seconds: 1), () {
//       if (resendSeconds.value > 0) {
//         resendSeconds.value--;
//         startResendTimer();
//       }
//     });
//   }

//   // For PinCodeTextField
//   void updateOtp(String code) {
//     otpCode.value = code;
//   }

//   void addDigit(String digit) {
//     if (otpCode.value.length < 6) {
//       otpCode.value += digit;
//     }
//   }

//   void removeDigit() {
//     if (otpCode.value.isNotEmpty) {
//       otpCode.value = otpCode.value.substring(0, otpCode.value.length - 1);
//     }
//   }

//   Future<void> verifyOtp() async {
//     if (otpCode.value.length != 6) {
//       Get.snackbar('Error', 'Enter 6-digit code');
//       return;
//     }
//     isLoading.value = true;
//     try {
//       if (purpose == 'login') {
//         // Call API to verify OTP and get token/user
//         final user = await _userRepository.loginWithOtp(
//           otpCode.value,
//           identifier,
//         );
//         if (user != null) {
//           _storage.token = 'dummy_token'; // replace with actual token
//           _storage.user = user;
//           Get.offNamed(AppRoutes.ROLE_SELECTION);
//         } else {
//           Get.snackbar('Error', 'OTP verification failed');
//         }
//       } else {
//         // Forgot password: just go to reset (identifier passed)
//         Get.offNamed(
//           AppRoutes.RESET_PASSWORD,
//           arguments: {'identifier': identifier},
//         );
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void resendCode() async {
//     resendSeconds.value = 45;
//     startResendTimer();
//     // Resend OTP to the same identifier
//     await _userRepository.sendOtp(identifier);
//     Get.snackbar('Success', 'OTP resent');
//   }
// }

import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:erp_frontend/common/utils/auth_route_resolver.dart';
import 'package:get/get.dart';
import '../../../services/app_storage.dart';

class OtpController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final _storage = AppStorage();

  final otpCode = ''.obs;
  final isLoading = false.obs;
  final resendSeconds = 45.obs;
  late String purpose;
  late String identifier; // email/phone

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {}; // Prevent null
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
        final user = await _userRepository.loginWithOtp(
          otpCode.value,
          identifier,
        );
        if (user != null) {
          // OTP flow is legacy/mock in this build.
          // Keep storage clear so API-backed screens don't use fake tokens.
          _storage.token = null;
          _storage.user = user;
          final roleStr = user.role.toString().split('.').last;
          AuthRouteResolver.goHomeForRole(roleStr);
        } else {
          AppToast.show('OTP verification failed');
        }
      } else {
        Get.offNamed(
          AppRoutes.RESET_PASSWORD,
          arguments: {'identifier': identifier},
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void resendCode() async {
    resendSeconds.value = 45;
    startResendTimer();
    await _userRepository.sendOtp(identifier);
    AppToast.show('OTP resent');
  }
}
