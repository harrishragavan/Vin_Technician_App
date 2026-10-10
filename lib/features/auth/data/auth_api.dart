import '../../../core/api/api_client.dart';

/// Raw calls to `vin_chakra/mobile/v1/auth.py`. Kept separate from
/// [AuthRepository] so the HTTP shape (field names, GET vs POST) is
/// isolated from app-level concerns like token storage.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  /// No login needed. Returns company name, logo, site time zone, minimum
  /// app version and enabled features. Called once on first launch, and
  /// again whenever the site URL changes.
  Future<Map<String, dynamic>> bootstrap() {
    return _client.get<Map<String, dynamic>>('auth.bootstrap');
  }

  /// Returns `{api_key, api_secret, profile: {name, roles, employee,
  /// home_screen}}`. Rotates the user's API secret server-side, so signing
  /// in here signs the user out everywhere else.
  Future<Map<String, dynamic>> login({
    required String usernameOrMobile,
    required String password,
    required String deviceId,
    required String deviceModel,
    required String appVersion,
    required String clientRequestId,
  }) {
    return _client.post<Map<String, dynamic>>(
      'auth.login',
      clientRequestId: clientRequestId,
      data: {
        'usr': usernameOrMobile,
        'pwd': password,
        'device_id': deviceId,
        'device_model': deviceModel,
        'app_version': appVersion,
      },
    );
  }

  /// Confirms the stored token is still valid and returns the current
  /// profile. Called in the background on every launch.
  Future<Map<String, dynamic>> me() {
    return _client.get<Map<String, dynamic>>('auth.me');
  }

  /// Rotates the secret (invalidating the current token) and removes the
  /// push token registration.
  Future<void> logout({required String clientRequestId}) {
    return _client.post<void>('auth.logout', clientRequestId: clientRequestId);
  }

  Future<void> registerPush({
    required String fcmToken,
    required String clientRequestId,
  }) {
    return _client.post<void>(
      'auth.register_push',
      clientRequestId: clientRequestId,
      data: {'fcm_token': fcmToken},
    );
  }
}
