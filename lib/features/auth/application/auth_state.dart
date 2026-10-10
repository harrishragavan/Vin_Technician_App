import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/storage/secure_token_store.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  /// Checking for a compiled/stored site URL and a saved token.
  loading,

  /// No usable site URL yet (debug/staging builds only) — show the URL
  /// field + QR scanner.
  needsSiteUrl,

  /// The site URL resolved but `auth.bootstrap` failed (wrong URL, site
  /// down, app below the minimum version).
  bootstrapFailed,

  /// No valid session — show the sign-in screen.
  signedOut,

  signedIn,
}

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.loading) AuthStatus status,
    AuthCredentials? credentials,
    Map<String, dynamic>? bootstrapInfo,
    String? errorMessage,
    String? errorDetail,
  }) = _AuthState;
}
