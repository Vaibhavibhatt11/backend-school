class ApiConfig {
  ApiConfig._();

  /// Production backend URL used by distributed APK builds.
  static const String baseUrl = 'https://backend-school-app.onrender.com/api/v1';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}

