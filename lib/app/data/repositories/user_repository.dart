import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';

class UserRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<UserModel?> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // Dummy response for demo
    return UserModel(
      id: '1',
      name: 'John Doe',
      email: 'user@example.com',
      phone: '+1234567890',
      role: UserRole.parent, // change based on selection
    );
  }

  // Add these methods
  Future<bool> requestLoginOtp(String emailOrPhone, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // In real app, check credentials and send OTP
    return true; // success
  }

  Future<UserModel?> loginWithOtp(String otp, String identifier) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      // Dummy user
      return UserModel(
        id: '1',
        name: 'John Doe',
        email: identifier,
        phone: identifier,
        role: UserRole.parent,
      );
    }
    return null;
  }

  Future<bool> sendOtp(String phoneOrEmail) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return code == '123456'; // dummy
  }

  Future<bool> resetPassword(String emailOrPhone, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
