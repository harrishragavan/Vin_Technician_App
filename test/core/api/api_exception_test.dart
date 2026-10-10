import 'package:flutter_test/flutter_test.dart';
import 'package:vin_technician_app/core/api/api_exception.dart';

void main() {
  group('ApiException', () {
    test('isUnauthorized is true only for HTTP 401', () {
      const unauthorized = ApiException(
        statusCode: 401,
        code: 'INVALID_TOKEN',
        message: 'Session expired',
      );
      const forbidden = ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: 'Not allowed',
      );

      expect(unauthorized.isUnauthorized, isTrue);
      expect(forbidden.isUnauthorized, isFalse);
    });

    test('isNetworkError and isUnreachableSite map to the right codes', () {
      const offline = ApiException(
        statusCode: 0,
        code: ApiException.offline,
        message: 'No connection',
      );
      const unreachable = ApiException(
        statusCode: 0,
        code: ApiException.unreachableSite,
        message: "Can't reach this site",
      );

      expect(offline.isNetworkError, isTrue);
      expect(offline.isUnreachableSite, isFalse);
      expect(unreachable.isUnreachableSite, isTrue);
      expect(unreachable.isNetworkError, isFalse);
    });
  });
}
