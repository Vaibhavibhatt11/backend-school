import 'package:dio/dio.dart' as dio;

import 'package:get/get.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/auth/login_response_model.dart';
import 'parent/parent_context_service.dart';
import 'session_storage_service.dart';

class AuthService {
  AuthService(this._apiClient, this._sessionStorage);

  final ApiClient _apiClient;
  final SessionStorageService _sessionStorage;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final dio.Response<dynamic> response = await _apiClient.post(
      ApiEndpoints.authLogin,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    final dynamic body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid login response format.');
    }

    final parsed = LoginResponseModel.fromJson(body);
    if (parsed.token.isEmpty) {
      throw Exception(parsed.message ?? 'Login failed. Token not found.');
    }

    // Store full login response + token in SharedPreferences
    await _sessionStorage.saveLoginResponse(parsed.raw);
    await _sessionStorage.saveToken(parsed.token);
    return parsed;
  }

  Future<Map<String, dynamic>> refresh() async {
    final refreshToken = await _sessionStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available.');
    }
    final dio.Response<dynamic> response = await _apiClient.post(
      ApiEndpoints.authRefresh,
      data: {'refreshToken': refreshToken},
    );
    final dynamic body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid refresh response format.');
    }
    final success = body['success'];
    if (success == false) {
      final message = body['message'];
      if (message != null && message.toString().isNotEmpty) {
        throw Exception(message.toString());
      }
      final err = body['error'];
      if (err is Map && err['message'] != null) {
        throw Exception(err['message'].toString());
      }
      throw Exception('Refresh failed.');
    }
    await _sessionStorage.saveLoginResponse(body);
    final parsed = LoginResponseModel.fromJson(body);
    if (parsed.token.isNotEmpty) {
      await _sessionStorage.saveToken(parsed.token);
    }
    return body;
  }

  /// Revokes refresh token on server (best-effort) and clears local session.
  Future<void> logout() async {
    final rt = await _sessionStorage.getRefreshToken();
    try {
      await _apiClient.post(
        ApiEndpoints.authLogout,
        data: (rt != null && rt.isNotEmpty) ? {'refreshToken': rt} : null,
      );
    } catch (_) {
      // Still clear local session if network fails.
    }
    try {
      if (Get.isRegistered<ParentContextService>()) {
        Get.find<ParentContextService>().setSelectedChildId(null);
      }
    } catch (_) {}
    await _sessionStorage.clearSession();
  }

  Future<Map<String, dynamic>> me() async {
    final dio.Response<dynamic> response =
        await _apiClient.get(ApiEndpoints.authMe);
    final dynamic body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid profile response format.');
    }
    return body;
  }
}

