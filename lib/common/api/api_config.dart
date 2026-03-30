class ApiConfig {
  ApiConfig._();

  /// Backend base URL (must include `/api/v1` if your server mounts there).
  ///
  /// - Release APKs and `flutter run --release` use this unless overridden at compile time:
  ///   `flutter build apk --release --dart-define=API_BASE_URL=https://your-host/api/v1`
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.trim().isNotEmpty) return fromEnv.trim();
    return 'https://backend-school-app.onrender.com/api/v1';
  }

  // Render apps may take extra time to respond on cold start.
  // Keep timeouts higher so the UI doesn't show "Cannot reach server".
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}

