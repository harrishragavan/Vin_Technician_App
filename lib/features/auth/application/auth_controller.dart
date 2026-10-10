import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/providers.dart';
import '../../../core/db/providers.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) return null;
  return AuthRepository(
    api: AuthApi(client),
    store: ref.watch(secureTokenStoreProvider),
  );
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Owns the whole sign-in lifecycle described in the plan's "Login and
/// setup" section: resolve the site URL, call `auth.bootstrap`, restore a
/// saved token, confirm it with `auth.me`, and react to a 401 from
/// anywhere in the app by returning to sign-in.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.listen(forceSignOutTickProvider, (previous, next) {
      if (previous != null && next != previous) {
        signOut(notifyServer: false);
      }
    });
    Future.microtask(start);
    return const AuthState();
  }

  Future<void> start() async {
    final baseUrl = await ref.read(baseUrlProvider.future);
    if (baseUrl == null || baseUrl.isEmpty) {
      state = state.copyWith(status: AuthStatus.needsSiteUrl);
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      state = state.copyWith(status: AuthStatus.needsSiteUrl);
      return;
    }

    try {
      final bootstrapInfo = await repo.bootstrap();
      state = state.copyWith(bootstrapInfo: bootstrapInfo);
    } on ApiException catch (error) {
      state = state.copyWith(
        status: AuthStatus.bootstrapFailed,
        errorMessage: error.message,
      );
      return;
    }

    final saved = await repo.restoreSession();
    if (saved == null) {
      state = state.copyWith(status: AuthStatus.signedOut);
      return;
    }

    // Open straight onto cached data; confirm the token in the background.
    state = state.copyWith(status: AuthStatus.signedIn, credentials: saved);
    try {
      final refreshed = await repo.refreshProfile(saved);
      state = state.copyWith(credentials: refreshed);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await signOut(notifyServer: false);
      }
      // Any other error (offline, unreachable) keeps the cached session —
      // the user carries on with what was last loaded.
    }
  }

  Future<void> setSiteUrl(String url) async {
    await ref.read(secureTokenStoreProvider).saveSiteUrl(url);
    ref.invalidate(baseUrlProvider);
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    await start();
  }

  Future<void> signIn({
    required String usernameOrMobile,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return;
    final credentials = await repo.signIn(
      usernameOrMobile: usernameOrMobile,
      password: password,
    );
    state = state.copyWith(
      status: AuthStatus.signedIn,
      credentials: credentials,
      errorMessage: null,
    );
  }

  Future<void> signOut({bool notifyServer = true}) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo != null) {
      await repo.signOut(notifyServer: notifyServer);
    }
    // No one should see the previous user's cached jobs after sign-out or
    // when a different user signs in on this phone.
    await ref.read(appDatabaseProvider).clearAllData();
    state = state.copyWith(status: AuthStatus.signedOut, credentials: null);
  }
}
