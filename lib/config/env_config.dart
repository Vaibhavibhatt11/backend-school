class EnvConfig {
  static String apiBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-school-app.onrender.com/api/v1',
  );

  static void init() {
    // Base URL is configured via --dart-define=API_BASE_URL.
  }
}
