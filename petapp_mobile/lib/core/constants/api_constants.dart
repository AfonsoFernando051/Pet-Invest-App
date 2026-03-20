class ApiConstants {
  // Use http://10.0.2.2:8081 for Android Emulator to connect to localhost
  // Use http://localhost:8081 for iOS Simulator or Web
  static const String baseUrl = 'http://10.0.2.2:8081';

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
}
