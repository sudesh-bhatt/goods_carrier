import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/settings/presentation/providers/locale_provider.dart';
import '../providers/session_expired_provider.dart';
import '../providers/shared_preferences_provider.dart';
import 'api_constants.dart';
import 'device_info_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/headers_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/response_interceptor.dart';

// ─── Secure Storage provider ──────────────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

List<Interceptor> _dioInterceptors(
  Ref ref,
  FlutterSecureStorage storage,
  DeviceInfoService deviceInfo,
) {
  return [
    HeadersInterceptor(
      deviceInfo: deviceInfo,
      languageCode: () => ref.read(localeProvider).languageCode,
    ),
    AuthInterceptor(
      storage: storage,
      prefs: ref.read(sharedPreferencesProvider),
      onSessionExpired: () {
        Future.microtask(() => signalSessionExpiredFromRef(ref));
      },
    ),
    ResponseInterceptor(),
    ErrorInterceptor(),
    if (kDebugMode) LoggingInterceptor(),
  ];
}

// ─── Dio provider ─────────────────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);
  final deviceInfo = ref.read(deviceInfoServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll(_dioInterceptors(ref, storage, deviceInfo));

  return dio;
});

/// Dio for already-absolute URLs (e.g. `/storage/...` assets resolved to full URL).
///
/// Avoids concatenating [ApiConstants.baseUrl] onto an absolute [RequestOptions.path].
final absoluteUrlDioProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);
  final deviceInfo = ref.read(deviceInfoServiceProvider);

  final dio = Dio(
    BaseOptions(
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
    ),
  );

  dio.interceptors.addAll(_dioInterceptors(ref, storage, deviceInfo));

  return dio;
});
