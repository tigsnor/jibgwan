class ApiConstants {
  static const String apiBaseUrl = 'https://your-firebase-function-url.com';

  // Auth 관련 엔드포인트
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String logoutEndpoint = '/auth/logout';
  static const String approveUserEndpoint = '/auth/approve';
  static const String rejectUserEndpoint = '/auth/reject';
  static const String getUserRoleEndpoint = '/auth/role';
}
