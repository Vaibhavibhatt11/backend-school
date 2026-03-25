import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _loginResponseKey = 'login_response_json';

  SharedPreferences? _prefs;

  Future<void> _ensureReady() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _ensureReady();
    await _prefs!.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    await _ensureReady();
    return _prefs!.getString(_tokenKey);
  }

  Future<void> saveLoginResponse(Map<String, dynamic> json) async {
    await _ensureReady();
    await _prefs!.setString(_loginResponseKey, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> getLoginResponse() async {
    await _ensureReady();
    final raw = _prefs!.getString(_loginResponseKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _ensureReady();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_loginResponseKey);
  }
}

