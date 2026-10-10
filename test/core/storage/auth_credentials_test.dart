import 'package:flutter_test/flutter_test.dart';
import 'package:vin_technician_app/core/storage/secure_token_store.dart';

AuthCredentials _credentialsWith({
  required List<String> roles,
  String? homeScreen,
}) {
  return AuthCredentials(
    apiKey: 'key',
    apiSecret: 'secret',
    profile: {'roles': roles, 'home_screen': ?homeScreen},
  );
}

void main() {
  group('AuthCredentials role checks', () {
    test('Agent and TP Agent count as technician', () {
      expect(_credentialsWith(roles: ['Agent']).isTechnician, isTrue);
      expect(_credentialsWith(roles: ['TP Agent']).isTechnician, isTrue);
      expect(
        _credentialsWith(roles: ['Chief Technician']).isTechnician,
        isFalse,
      );
    });

    test('Chief Technician and System Manager count as chief', () {
      expect(
        _credentialsWith(roles: ['Chief Technician']).isChiefTechnician,
        isTrue,
      );
      expect(
        _credentialsWith(roles: ['System Manager']).isChiefTechnician,
        isTrue,
      );
      expect(_credentialsWith(roles: ['Agent']).isChiefTechnician, isFalse);
    });

    test('hasBothHomes requires both a technician and a chief role', () {
      expect(
        _credentialsWith(roles: ['Agent', 'Chief Technician']).hasBothHomes,
        isTrue,
      );
      expect(_credentialsWith(roles: ['Agent']).hasBothHomes, isFalse);
    });

    test('homeScreen prefers the server value over role inference', () {
      final credentials = _credentialsWith(
        roles: ['Agent', 'Chief Technician'],
        homeScreen: 'technician',
      );
      expect(credentials.homeScreen, 'technician');
    });

    test('homeScreen falls back to chief when the server omits it', () {
      final credentials = _credentialsWith(
        roles: ['Agent', 'Chief Technician'],
      );
      expect(credentials.homeScreen, 'chief');
    });

    test('authorizationHeader formats as "token key:secret"', () {
      final credentials = _credentialsWith(roles: ['Agent']);
      expect(credentials.authorizationHeader, 'token key:secret');
    });
  });
}
