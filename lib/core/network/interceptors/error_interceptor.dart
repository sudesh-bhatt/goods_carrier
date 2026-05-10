import 'package:dio/dio.dart';

import '../app_exception.dart';

/// Converts every [DioException] into a typed [AppException] so callers
/// never need to depend on `package:dio` in presentation or domain layers.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = AppException.fromDioException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response:       err.response,
        type:           err.type,
        error:          appError,
        message:        appError.message,
      ),
    );
  }
}
