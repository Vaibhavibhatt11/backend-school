import '../../config/env_config.dart';

class ApiConfig {
  ApiConfig._();

  /// Shared API URL for all HTTP clients.
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // Render apps may take extra time to respond on cold start.
  // Keep timeouts higher so the UI doesn't show "Cannot reach server".
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}

