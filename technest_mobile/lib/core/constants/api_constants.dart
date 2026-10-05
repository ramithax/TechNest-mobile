class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5031',
  );

  static const String login = '/api/Auth/login';
  static const String refreshToken = '/api/Auth/refresh-token';
  static const String googleLogin = '/api/Auth/google';
  static const String repairs = '/api/Repair';
  static const String pcBuild = '/api/PcBuild';
  static const String products = '/api/Product';
  static const String register = '/api/Auth/register';
  static const String forgotPassword = '/api/Auth/forgot-password';
  static const String resetPassword = '/api/Auth/reset-password';
  static const String updateProfile = '/api/Auth/profile';
}
