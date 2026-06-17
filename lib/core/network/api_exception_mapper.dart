import 'package:dio/dio.dart';

import '../../l10n/app_localizations.dart';
import 'app_exception.dart';

/// Maps thrown errors to user-facing messages.
abstract final class ApiExceptionMapper {
  static AppException from(Object error) {
    if (error is AppException) return error;
    if (error is DioException) {
      final inner = error.error;
      if (inner is AppException) return inner;
      return AppException.fromDioException(error);
    }
    return UnknownException(error.toString());
  }

  static String userMessage(Object error, [AppLocalizations? l10n]) {
    final appError = from(error);
    if (appError.message.isNotEmpty &&
        !appError.message.startsWith('AppException')) {
      return appError.message;
    }
    return switch (appError) {
      NetworkException() =>
        'No internet connection. Please check your network.',
      TimeoutException() => 'Request timed out. Please try again.',
      UnauthorisedException() => 'Session expired. Please log in again.',
      ForbiddenException() => 'You don\'t have permission to do this.',
      ValidationException(:final message) => message,
      ServerException(:final message) => message,
      RequestCancelledException() => 'Request was cancelled.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
