class ApiConstants {
  // Use http://10.0.2.2:8081 for Android Emulator to connect to localhost
  // Use http://localhost:8081 for iOS Simulator or Web
  static const String baseUrl = 'http://localhost:8081';

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';

  static const String onboardingQuestionsEndpoint = '/api/onboarding/questions';
  static const String onboardingSubmitEndpoint = '/api/onboarding/submit';
  static const String onboardingStatusEndpoint = '/api/onboarding/status';
}
