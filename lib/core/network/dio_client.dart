import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

// ─── Secure Storage provider ──────────────────────────────────────────────────

/// Single [FlutterSecureStorage] instance shared across the app.
///
/// Android: uses EncryptedSharedPreferences (API 23+).
/// iOS: uses Keychain with accessible-when-unlocked policy.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

// ─── Dio provider ─────────────────────────────────────────────────────────────

/// Fully configured [Dio] instance with:
///   - [AuthInterceptor]    — Bearer token + silent refresh
///   - [ErrorInterceptor]   — DioException → AppException mapping
///   - [LoggingInterceptor] — console output in debug mode only
///
/// Consume via `ref.read(dioProvider)` inside repositories.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl:        ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout:    ApiConstants.sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept':       'application/json',
        'X-Platform':   'flutter',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(dio: dio, storage: storage),
    ErrorInterceptor(),
    if (kDebugMode) LoggingInterceptor(),
  ]);

  return dio;
});
