import 'package:get/get.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_endpoints.dart';
import '../../../common/services/parent/parent_api_utils.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository() : _apiClient = Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<UserModel?> login(String email, String password) async {
    final res = await _apiClient.post(
      ApiEndpoints.authLogin,
      data: {'email': email.trim(), 'password': password},
    );
    final data = extractApiData(res.data, context: 'login');
    final user = data['user'];
    if (user is! Map<String, dynamic>) return null;
    return UserModel(
      id: user['id']?.toString() ?? '',
      name: user['fullName']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      phone: '',
      role: _mapRole(user['role']?.toString()),
    );
  }

  Future<bool> requestLoginOtp(String emailOrPhone, String password) async {
    throw Exception('OTP login is not enabled. Please sign in with password.');
  }

  Future<UserModel?> loginWithOtp(String otp, String identifier) async {
    throw Exception('OTP login is not enabled. Please sign in with password.');
  }

  Future<bool> sendOtp(String phoneOrEmail) async {
    await _apiClient.post(
      ApiEndpoints.authForgotPassword,
      data: {'email': phoneOrEmail.trim()},
    );
    return true;
  }

  Future<String> verifyOtpForReset({
    required String email,
    required String otp,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.authVerifyOtp,
      data: {'email': email.trim(), 'otp': otp.trim()},
    );
    final data = extractApiData(res.data, context: 'verify otp');
    final token = data['resetToken']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('Reset token not returned by server.');
    }
    return token;
  }

  Future<bool> verifyOtp(String code) async {
    throw Exception('Use verifyOtpForReset(email, otp) instead.');
  }

  Future<bool> resetPassword(String resetToken, String newPassword) async {
    await _apiClient.post(
      ApiEndpoints.authResetPassword,
      data: {'resetToken': resetToken, 'newPassword': newPassword},
    );
    return true;
  }

  UserRole _mapRole(String? role) {
    switch ((role ?? '').toUpperCase()) {
      case 'SCHOOLADMIN':
      case 'SUPERADMIN':
      case 'HR':
      case 'ACCOUNTANT':
      case 'ADMIN':
        return UserRole.admin;
      case 'TEACHER':
      case 'STAFF':
        return UserRole.teacher;
      case 'LIBRARIAN':
        return UserRole.librarian;
      case 'HOSTEL_WARDEN':
        return UserRole.hostelWarden;
      case 'PARENT':
      default:
        return UserRole.parent;
    }
  }
}
