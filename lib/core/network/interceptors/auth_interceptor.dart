import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api_constants.dart';

/// Attaches the Bearer token to every outgoing request and transparently
/// refreshes it when a 401 is received.
///
/// Token lifecycle:
///   1. `onRequest` — reads [kAccessToken] from [FlutterSecureStorage] and
///      appends `Authorization: Bearer <token>` if present.
///   2. `onError` — when the server returns 401, attempts one silent refresh
///      via [ApiConstants.refreshToken] and retries the original request.
///      If the refresh also fails, clears both tokens so the router redirects
///      the user to the login screen.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.storage});

  final Dio                  dio;
  final FlutterSecureStorage storage;

  @override
  Future<void> onRequest(
    RequestOptions         options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for token-issuing endpoints
    final isAuthEndpoint = [
      ApiConstants.sendOtp,
      ApiConstants.verifyOtp,
      ApiConstants.refreshToken,
    ].any((path) => options.path.endsWith(path));

    if (!isAuthEndpoint) {
      final token = await storage.read(key: ApiConstants.kAccessToken);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException          err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Avoid retry loop on the refresh endpoint itself
    if (err.requestOptions.path.endsWith(ApiConstants.refreshToken)) {
      await _clearTokens();
      return handler.next(err);
    }

    try {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        await _clearTokens();
        return handler.next(err);
      }

      // Retry with the new access token
      final newToken = await storage.read(key: ApiConstants.kAccessToken);
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      await _clearTokens();
      return handler.next(err);
    }
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await storage.read(key: ApiConstants.kRefreshToken);
    if (refreshToken == null) return false;

    final response = await dio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final newAccess  = response.data['access_token']  as String?;
    final newRefresh = response.data['refresh_token'] as String?;

    if (newAccess == null) return false;

    await Future.wait([
      storage.write(key: ApiConstants.kAccessToken,  value: newAccess),
      if (newRefresh != null)
        storage.write(key: ApiConstants.kRefreshToken, value: newRefresh),
    ]);

    return true;
  }

  Future<void> _clearTokens() => Future.wait([
        storage.delete(key: ApiConstants.kAccessToken),
        storage.delete(key: ApiConstants.kRefreshToken),
      ]);
}
