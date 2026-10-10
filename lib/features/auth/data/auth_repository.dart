import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/secure_token_store.dart';
import 'auth_api.dart';

/// Bridges [AuthApi] (HTTP shape) and [SecureTokenStore] (persistence) so
/// `AuthController` only deals in [AuthCredentials] and plain outcomes.
class AuthRepository {
  AuthRepository({required AuthApi api, required SecureTokenStore store})
    : _api = api,
      _store = store;

  final AuthApi _api;
  final SecureTokenStore _store;

  Future<Map<String, dynamic>> bootstrap() => _api.bootstrap();

  Future<AuthCredentials?> restoreSession() => _store.read();

  Future<AuthCredentials> signIn({
    required String usernameOrMobile,
    required String password,
  }) async {
    final deviceId = await _store.deviceId();
    final packageInfo = await PackageInfo.fromPlatform();
    final response = await _api.login(
      usernameOrMobile: usernameOrMobile,
      password: password,
      deviceId: deviceId,
      deviceModel: 'android',
      appVersion: packageInfo.version,
      clientRequestId: const Uuid().v4(),
    );

    final credentials = AuthCredentials(
      apiKey: response['api_key'] as String,
      apiSecret: response['api_secret'] as String,
      profile: (response['profile'] as Map).cast<String, dynamic>(),
    );
    await _store.save(credentials);
    return credentials;
  }

  /// Confirms the stored token still works and refreshes the cached
  /// profile (roles can change server-side between launches).
  Future<AuthCredentials> refreshProfile(AuthCredentials current) async {
    final profile = await _api.me();
    final refreshed = AuthCredentials(
      apiKey: current.apiKey,
      apiSecret: current.apiSecret,
      profile: profile,
    );
    await _store.save(refreshed);
    return refreshed;
  }

  Future<void> signOut({bool notifyServer = true}) async {
    if (notifyServer) {
      try {
        await _api.logout(clientRequestId: const Uuid().v4());
      } catch (_) {
        // The secret is rotated server-side regardless; clearing the local
        // copy below is what actually matters for "signed out" on this
        // device, so a failed logout call (e.g. offline) is not fatal.
      }
    }
    await _store.clear();
  }
}
