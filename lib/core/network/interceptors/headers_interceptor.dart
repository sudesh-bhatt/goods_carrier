import 'package:dio/dio.dart';

import '../device_info_service.dart';

/// Injects device, FCM, and language headers required by the Goods Carrier API.
class HeadersInterceptor extends Interceptor {
  HeadersInterceptor({
    required this.deviceInfo,
    required this.languageCode,
    required this.fcmToken,
  });

  final DeviceInfoService deviceInfo;
  final String Function() languageCode;

  /// Current FCM registration token, or `null` before permission / init.
  final String? Function() fcmToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = languageCode();
    options.headers['X-Device-Id'] = deviceInfo.deviceId;
    options.headers['X-Device-Type'] = deviceInfo.deviceType;

    final token = fcmToken()?.trim();
    if (token != null && token.isNotEmpty) {
      options.headers['X-FCM-Token'] = token;
    } else {
      options.headers.remove('X-FCM-Token');
    }

    final isMultipart = options.data is FormData;
    if (isMultipart) {
      // BaseOptions defaults to application/json; Dio must set multipart boundary.
      options.headers.remove(Headers.contentTypeHeader);
    } else {
      options.headers.putIfAbsent(
        Headers.contentTypeHeader,
        () => Headers.jsonContentType,
      );
    }
    options.headers.putIfAbsent('Accept', () => 'application/json');

    handler.next(options);
  }
}
