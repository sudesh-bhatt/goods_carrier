import 'package:dio/dio.dart';

import '../device_info_service.dart';

/// Injects device and language headers required by the Goods Carrier API.
class HeadersInterceptor extends Interceptor {
  HeadersInterceptor({
    required this.deviceInfo,
    required this.languageCode,
  });

  final DeviceInfoService deviceInfo;
  final String Function() languageCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = languageCode();
    options.headers['X-Device-Id'] = deviceInfo.deviceId;
    options.headers['X-Device-Type'] = deviceInfo.deviceType;

    final isMultipart = options.data is FormData;
    if (!isMultipart) {
      options.headers.putIfAbsent('Content-Type', () => 'application/json');
    }
    options.headers.putIfAbsent('Accept', () => 'application/json');

    handler.next(options);
  }
}
