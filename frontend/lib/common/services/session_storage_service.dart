import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _legacyTokenKey = 'token';
  static const String _loginResponseKey = 'login_response_json';

  SharedPreferences? _prefs;
  String? _cachedToken;
  Map<String, dynamic>? _cachedLoginResponse;
  bool _loginResponseLoaded = false;

  Future<void> _ensureReady() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _ensureReady();
    _cachedToken = token;
    await _prefs!.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    await _ensureReady();
    final token = _prefs!.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      _cachedToken = token;
      return token;
    }
    // Fallback for legacy auth flow that stores token in GetStorage.
    final legacy = GetStorage().read<String>(_legacyTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      _cachedToken = legacy;
      return legacy;
    }
    return null;
  }

  Future<void> saveLoginResponse(Map<String, dynamic> json) async {
    await _ensureReady();
    _cachedLoginResponse = Map<String, dynamic>.from(json);
    _loginResponseLoaded = true;
    await _prefs!.setString(_loginResponseKey, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> getLoginResponse() async {
    if (_loginResponseLoaded) return _cachedLoginResponse;
    await _ensureReady();
    final raw = _prefs!.getString(_loginResponseKey);
    if (raw == null || raw.isEmpty) {
      _loginResponseLoaded = true;
      _cachedLoginResponse = null;
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _cachedLoginResponse = decoded;
      } else {
        _cachedLoginResponse = null;
      }
      _loginResponseLoaded = true;
      return _cachedLoginResponse;
    } catch (_) {
      _loginResponseLoaded = true;
      _cachedLoginResponse = null;
      return null;
    }
  }

  /// Refresh JWT from last [saveLoginResponse] (`data.refreshToken`).
  Future<String?> getRefreshToken() async {
    final login = await getLoginResponse();
    if (login == null) return null;
    final data = login['data'];
    if (data is Map<String, dynamic>) {
      final rt = data['refreshToken'];
      if (rt != null && rt.toString().isNotEmpty) return rt.toString();
    }
    return null;
  }

  Future<void> clearSession() async {
    await _ensureReady();
    _cachedToken = null;
    _cachedLoginResponse = null;
    _loginResponseLoaded = true;
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_loginResponseKey);
  }
}

