import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// The signed-in user's API key/secret pair and cached profile, backed by
/// the Android Keystore via flutter_secure_storage. There is exactly one
/// pair at a time: signing in rotates the server-side secret, so an old
/// phone's copy stops working the moment a new one signs in (see Login and
/// setup → Sign-in, step 4 of the plan).
class AuthCredentials {
  const AuthCredentials({
    required this.apiKey,
    required this.apiSecret,
    required this.profile,
  });

  final String apiKey;
  final String apiSecret;

  /// Raw profile JSON from `auth.login`/`auth.me`: name, roles, employee,
  /// home screen.
  final Map<String, dynamic> profile;

  String get authorizationHeader => 'token $apiKey:$apiSecret';

  List<String> get roles =>
      (profile['roles'] as List?)?.cast<String>() ?? const [];

  bool get isTechnician =>
      roles.contains('Agent') || roles.contains('TP Agent');

  bool get isChiefTechnician =>
      roles.contains('Chief Technician') || roles.contains('System Manager');

  /// A user with both role sets gets a switch in the profile menu (plan,
  /// "Screens"); the server's `home_screen` picks which one opens first.
  bool get hasBothHomes => isTechnician && isChiefTechnician;

  /// `'technician'` or `'chief'`, as returned by `auth.login`/`auth.me`.
  /// Falls back to role inference if the server omits it.
  String get homeScreen {
    final fromServer = profile['home_screen'] as String?;
    if (fromServer != null) return fromServer;
    return isChiefTechnician ? 'chief' : 'technician';
  }
}

class SecureTokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          // Default AndroidOptions already uses AES-GCM with Keystore-backed
          // RSA-OAEP key wrapping (flutter_secure_storage 11.x).
          const FlutterSecureStorage(aOptions: AndroidOptions());

  final FlutterSecureStorage _storage;

  static const _keyApiKey = 'auth.api_key';
  static const _keyApiSecret = 'auth.api_secret';
  static const _keyProfile = 'auth.profile';
  static const _keyDeviceId = 'device.id';
  static const _keySiteUrl = 'site.url';

  Future<void> save(AuthCredentials credentials) async {
    await Future.wait([
      _storage.write(key: _keyApiKey, value: credentials.apiKey),
      _storage.write(key: _keyApiSecret, value: credentials.apiSecret),
      _storage.write(key: _keyProfile, value: jsonEncode(credentials.profile)),
    ]);
  }

  Future<AuthCredentials?> read() async {
    final values = await Future.wait([
      _storage.read(key: _keyApiKey),
      _storage.read(key: _keyApiSecret),
      _storage.read(key: _keyProfile),
    ]);
    final apiKey = values[0];
    final apiSecret = values[1];
    final profileJson = values[2];
    if (apiKey == null || apiSecret == null || profileJson == null) {
      return null;
    }
    return AuthCredentials(
      apiKey: apiKey,
      apiSecret: apiSecret,
      profile: jsonDecode(profileJson) as Map<String, dynamic>,
    );
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _keyApiKey),
      _storage.delete(key: _keyApiSecret),
      _storage.delete(key: _keyProfile),
    ]);
  }

  /// A UUID created once at install and reused for every sign-in on this
  /// device (sent to `auth.login` as `device_id`).
  Future<String> deviceId() async {
    final existing = await _storage.read(key: _keyDeviceId);
    if (existing != null) return existing;
    final generated = const Uuid().v4();
    await _storage.write(key: _keyDeviceId, value: generated);
    return generated;
  }

  /// Only used by staging/debug builds, where the site URL is typed or
  /// scanned from a QR code instead of being built into the release app.
  Future<void> saveSiteUrl(String url) =>
      _storage.write(key: _keySiteUrl, value: url);

  Future<String?> readSiteUrl() => _storage.read(key: _keySiteUrl);
}
