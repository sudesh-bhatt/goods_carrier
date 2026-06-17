import 'package:dio/dio.dart';

import '../app_exception.dart';

/// Validates API envelope on success responses.
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('success')) {
      final success = data['success'];
      if (success is bool && !success) {
        final message = data['message'] as String? ?? 'Request failed';
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: BadRequestException(message),
            message: message,
          ),
        );
        return;
      }
      if (data.containsKey('data')) {
        response.extra['envelope_data'] = data['data'];
      }
    }
    handler.next(response);
  }
}
