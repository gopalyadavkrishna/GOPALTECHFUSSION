abstract final class AppEnvironment {
  static const name = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const useDemoData = bool.fromEnvironment(
    'USE_DEMO_DATA',
    defaultValue: false,
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/v1',
  );

  static bool get isProduction => name == 'production';
}
