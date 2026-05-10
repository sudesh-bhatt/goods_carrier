import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Lightweight request / response / error logger active only in debug mode.
///
/// Intentionally minimal — no pretty-printing of large JSON bodies to keep
/// the console readable. Use Charles / Proxyman for deep inspection.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ [${options.method}] ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '← [${response.statusCode}] ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✗ [${err.response?.statusCode ?? "–"}] '
        '${err.requestOptions.uri}: ${err.message}',
      );
    }
    handler.next(err);
  }
}
