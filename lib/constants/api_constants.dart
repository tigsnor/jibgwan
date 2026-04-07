class ApiConstants {
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Auth 관련 엔드포인트
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String logoutEndpoint = '/auth/logout';
  static const String approveUserEndpoint = '/auth/approve';
  static const String rejectUserEndpoint = '/auth/reject';
  static const String getUserRoleEndpoint = '/auth/role';

  static Uri buildUri(String endpoint) {
    if (apiBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is not set. Pass --dart-define=API_BASE_URL=https://<region>-<project>.cloudfunctions.net',
      );
    }
    return Uri.parse('$apiBaseUrl$endpoint');
  }
}
