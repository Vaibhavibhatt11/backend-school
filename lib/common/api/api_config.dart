class ApiConfig {
  ApiConfig._();

  /// Production backend URL used by distributed APK builds.
  static const String baseUrl = 'https://backend-school-app.onrender.com/api/v1';

  // Render apps may take extra time to respond on cold start.
  // Keep timeouts higher so the UI doesn't show "Cannot reach server".
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}

