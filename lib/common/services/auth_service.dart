import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/auth/login_response_model.dart';
import 'session_storage_service.dart';

class AuthService {
  AuthService(this._apiClient, this._sessionStorage);

  final ApiClient _apiClient;
  final SessionStorageService _sessionStorage;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await _apiClient.post(
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
    final Response<dynamic> response = await _apiClient.post(ApiEndpoints.authRefresh);
    final dynamic body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid refresh response format.');
    }
    return body;
  }

  Future<Map<String, dynamic>> me() async {
    final Response<dynamic> response = await _apiClient.get(ApiEndpoints.authMe);
    final dynamic body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid profile response format.');
    }
    return body;
  }
}

