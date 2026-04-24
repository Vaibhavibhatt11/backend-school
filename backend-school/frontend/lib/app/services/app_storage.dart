import 'package:get_storage/get_storage.dart';
import '../data/models/user_model.dart';

class AppStorage {
  static final AppStorage _instance = AppStorage._internal();
  factory AppStorage() => _instance;
  AppStorage._internal();

  final _box = GetStorage();

  // Keys
  static const String _tokenKey = 'token';
  static const String _userRoleKey = 'userRole';
  static const String _userKey = 'user';
  static const String _themeKey = 'isDarkMode';

  // Token
  String? get token => _box.read(_tokenKey);
  set token(String? value) {
    if (value != null) {
      _box.write(_tokenKey, value);
    } else {
      _box.remove(_tokenKey);
    }
  }

  // User Role
  String? get userRole => _box.read(_userRoleKey);
  set userRole(String? value) {
    if (value != null) {
      _box.write(_userRoleKey, value);
    } else {
      _box.remove(_userRoleKey);
    }
  }

  // User Model (optional, store as JSON)
  UserModel? get user {
    final data = _box.read(_userKey);
    if (data != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  set user(UserModel? value) {
    if (value != null) {
      _box.write(_userKey, value.toJson());
    } else {
      _box.remove(_userKey);
    }
  }

  // Theme
  bool get isDarkMode => _box.read(_themeKey) ?? false;
  set isDarkMode(bool value) => _box.write(_themeKey, value);

  // Clear all (logout)
  void clearAll() {
    _box.erase();
  }
}
