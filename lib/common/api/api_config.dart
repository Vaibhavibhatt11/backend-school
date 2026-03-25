class ApiConfig {
  ApiConfig._();

  /// Provide via:
  /// flutter run --dart-define=API_BASE_URL=https://your-domain.com/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-school-app.onrender.com/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}

