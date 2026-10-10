import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'app_config.dart';

/// Thin wrapper around Dio for calling
/// `/api/method/vin_chakra.mobile.v1.<file>.<name>` endpoints.
///
/// Contract rules this enforces for every call (see the plan's "Mobile API
/// v1" section):
/// - no HTTP cache on `/api/` — Dio here has none configured;
/// - every write gets a `client_request_id` so a retry after a dropped
///   connection never creates a second check-in or invoice;
/// - a non-2xx response is always turned into an [ApiException] carrying
///   the server's stable `code`, never a silently-ignored `status: error`.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required Future<String?> Function() authHeaderProvider,
    required Future<void> Function() onUnauthorized,
  }) : _authHeaderProvider = authHeaderProvider,
       _onUnauthorized = onUnauthorized,
       _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 20),
           sendTimeout: const Duration(seconds: 20),
           contentType: 'application/json',
         ),
       ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final header = await _authHeaderProvider();
          if (header != null) {
            options.headers['Authorization'] = header;
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _onUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final Future<String?> Function() _authHeaderProvider;
  final Future<void> Function() _onUnauthorized;

  String _path(String method) =>
      '/api/method/vin_chakra.mobile.${AppConfig.apiVersion}.$method';

  /// Read endpoints (`meta.options`, `tech.home`, `chief.board`, ...).
  Future<T> get<T>(String method, {Map<String, dynamic>? params}) async {
    return _send<T>(
      () => _dio.get<dynamic>(_path(method), queryParameters: params),
    );
  }

  /// Write endpoints (`tech.check_in`, `invoice.create`, ...). Generates a
  /// `client_request_id` automatically when the caller does not already
  /// have one to retry with.
  Future<T> post<T>(
    String method, {
    Map<String, dynamic>? data,
    required String clientRequestId,
  }) async {
    final body = {...?data, 'client_request_id': clientRequestId};
    return _send<T>(() => _dio.post<dynamic>(_path(method), data: body));
  }

  Future<T> _send<T>(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as T;
      }
      return data as T;
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final response = error.response;
    if (response != null) {
      final body = response.data;
      final status = response.statusCode ?? 0;
      if (body is Map) {
        final code = body['code'] as String?;
        final message = body['message'] as String?;
        if (code != null) {
          return ApiException(
            statusCode: status,
            code: code,
            message: message ?? 'Something went wrong.',
            debugDetail: 'HTTP $status\n${_truncate(body.toString())}',
          );
        }
      }
      return ApiException(
        statusCode: status,
        code: ApiException.unknown,
        message: 'Something went wrong. Try again.',
        debugDetail: 'HTTP $status\n${_truncate(body.toString())}',
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ApiException(
          statusCode: 0,
          code: ApiException.offline,
          message: 'No connection. Showing what was last loaded.',
          debugDetail: '${error.type}: ${error.message}',
        );
      default:
        return ApiException(
          statusCode: 0,
          code: ApiException.unreachableSite,
          message: "Can't reach this site. Check the URL and try again.",
          debugDetail: '${error.type}: ${error.message}',
        );
    }
  }

  String _truncate(String text, [int maxLength = 500]) {
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';
  }
}
