class EnvConfig {
  // Override at build/run time:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-school-app.onrender.com/api/v1',
  );
  static String get apiBaseUrl =>
      _apiBaseUrl.trim().replaceAll(RegExp(r'\/+$'), '');

  static void init() {
    // no-op: retained for backward compatibility with existing startup code
  }
}
