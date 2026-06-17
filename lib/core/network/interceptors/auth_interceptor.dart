import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/auth_token_utils.dart';
import '../api_constants.dart';
import '../../../shared/data/local/auth_preferences_store.dart';

/// Attaches Bearer token and handles 401 session expiry.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.storage,
    required this.prefs,
    this.onSessionExpired,
  });

  final FlutterSecureStorage storage;
  final SharedPreferences prefs;
  final void Function()? onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = ApiConstants.publicPaths.any(
      (path) => options.path.endsWith(path),
    );

    if (!isPublic) {
      final token = await storage.read(key: ApiConstants.kAuthToken) ??
          await storage.read(key: ApiConstants.kAccessToken) ??
          prefs.getString(AuthPreferencesStore.authBearerTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] =
            AuthTokenUtils.authorizationHeader(token);
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    await _clearSession();
    onSessionExpired?.call();
    handler.next(err);
  }

  Future<void> _clearSession() => Future.wait([
        storage.delete(key: ApiConstants.kAuthToken),
        storage.delete(key: ApiConstants.kAccessToken),
        storage.delete(key: ApiConstants.kRefreshToken),
        storage.delete(key: ApiConstants.kOtpReferenceId),
        prefs.remove(AuthPreferencesStore.authBearerTokenKey),
      ]);
}
