import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../storage/secure_token_store.dart';
import 'api_client.dart';
import 'app_config.dart';

final secureTokenStoreProvider = Provider<SecureTokenStore>((ref) {
  return SecureTokenStore();
});

/// Resolves to the compiled production URL on a release build, or to
/// whatever was last saved by the site-setup screen on staging/debug
/// builds. `null` means the user still needs to enter or scan a site URL.
final baseUrlProvider = FutureProvider<String?>((ref) async {
  if (AppConfig.hasCompiledBaseUrl) {
    return AppConfig.compiledBaseUrl;
  }
  final store = ref.watch(secureTokenStoreProvider);
  return store.readSiteUrl();
});

/// Bumped whenever a 401 comes back from any call. `AuthController` listens
/// to this and moves the user back to sign-in without every feature screen
/// needing to know about auth — see `auth_controller.dart`.
final forceSignOutTickProvider = StateProvider<int>((ref) => 0);

/// `null` until [baseUrlProvider] has resolved to a non-empty URL. The
/// router gates on this: no screen other than site-setup/sign-in ever sees
/// a null client.
final apiClientProvider = Provider<ApiClient?>((ref) {
  final baseUrl = ref.watch(baseUrlProvider).value;
  if (baseUrl == null || baseUrl.isEmpty) return null;

  final store = ref.watch(secureTokenStoreProvider);
  return ApiClient(
    baseUrl: baseUrl,
    authHeaderProvider: () async {
      final credentials = await store.read();
      return credentials?.authorizationHeader;
    },
    onUnauthorized: () async {
      await store.clear();
      ref.read(forceSignOutTickProvider.notifier).state++;
    },
  );
});
