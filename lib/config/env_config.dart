class EnvConfig {
  static String apiBaseUrl = 'https://api.example.com';

  static void init() {
    // Load environment variables if needed
    const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
    if (environment == 'prod') {
      apiBaseUrl = 'https://api.prod.example.com';
    }
  }
}