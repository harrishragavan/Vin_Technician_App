/// Thrown for every non-2xx response from the mobile API. Mobile endpoints
/// always return `{"code": "...", "message": "..."}` on failure (contract
/// rule in the plan — never a bare HTTP 200 with `status: error`), so the
/// app can map [code] to a screen message instead of guessing from prose.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.debugDetail,
  });

  /// HTTP status code, e.g. 409 for ACTIVE_JOB_EXISTS.
  final int statusCode;

  /// Stable machine-readable code, e.g. "ATTENDANCE_REQUIRED".
  final String code;

  /// Human-readable fallback if the app has no copy for [code] yet.
  final String message;

  /// Raw diagnostic text (status line + a snippet of the response body, or
  /// the underlying Dio error) for screens that show it during development
  /// — the mobile API doesn't exist on most sites yet, so "what actually
  /// came back" matters more than a polished message right now.
  final String? debugDetail;

  /// The device has no usable connection (DNS/socket failure, timeout).
  bool get isNetworkError => code == offline;

  /// The server URL from site setup does not point at a vin_chakra site, or
  /// the site is unreachable — distinct from a plain offline device.
  bool get isUnreachableSite => code == unreachableSite;

  /// Session/token is no longer valid — the app should return to sign-in.
  bool get isUnauthorized => statusCode == 401;

  static const offline = 'OFFLINE';
  static const unreachableSite = 'UNREACHABLE_SITE';
  static const unknown = 'UNKNOWN_ERROR';

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}
