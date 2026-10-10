/// Build-time configuration. The release build gets its production URL
/// baked in with `--dart-define=API_BASE_URL=https://...` in CI (see
/// `.github/workflows/build.yml`), so technicians never type it. Staging and
/// debug builds leave this empty and fall back to the URL field + QR
/// scanner on first launch (see `SiteUrlController`).
class AppConfig {
  const AppConfig._();

  static const String compiledBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get hasCompiledBaseUrl => compiledBaseUrl.isNotEmpty;

  /// `vin_chakra/mobile/<version>` — bumped only on a breaking change; the
  /// server tells older apps to update via `auth.bootstrap`.
  static const String apiVersion = 'v1';
}
