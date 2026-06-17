import 'package:dio/dio.dart';

/// Typed exception hierarchy for all network failures.
///
/// Presentable via [message]; [statusCode] is set for HTTP errors.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int?   statusCode;

  // ── Factory ──────────────────────────────────────────────────────────────

  factory AppException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        final body = e.response?.data;
        final msg = _extractMessage(body);
        return switch (code) {
          400 => BadRequestException(msg ?? 'Bad request'),
          401 => const UnauthorisedException(),
          403 => const ForbiddenException(),
          404 => NotFoundException(msg ?? 'Resource not found'),
          422 => ValidationException(msg ?? 'Validation failed'),
          >= 500 => ServerException(
              msg ?? 'Server error ($code)',
              statusCode: code,
            ),
          _ => ServerException(msg ?? 'HTTP $code', statusCode: code),
        };

      case DioExceptionType.cancel:
        return const RequestCancelledException();

      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        return UnknownException(e.message ?? 'Unknown error occurred');
    }
  }

  static String? _extractMessage(dynamic body) {
    if (body is! Map) return null;
    final message = body['message'];
    if (message is String && message.isNotEmpty) return message;

    final errors = body['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is String && first.isNotEmpty) return first;
        }
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  @override
  String toString() => 'AppException($message)';
}

/// No internet / DNS failure.
final class NetworkException extends AppException {
  const NetworkException()
      : super('No internet connection. Please check your network.');
}

/// Connection or read/write timed out.
final class TimeoutException extends AppException {
  const TimeoutException()
      : super('Request timed out. Please try again.');
}

/// HTTP 400.
final class BadRequestException extends AppException {
  const BadRequestException(super.message);
}

/// HTTP 401 — token missing or expired.
final class UnauthorisedException extends AppException {
  const UnauthorisedException() : super('Session expired. Please log in again.', statusCode: 401);
}

/// HTTP 403.
final class ForbiddenException extends AppException {
  const ForbiddenException() : super('You don\'t have permission to do this.', statusCode: 403);
}

/// HTTP 404.
final class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

/// HTTP 422 — business validation failure.
final class ValidationException extends AppException {
  const ValidationException(super.message) : super(statusCode: 422);
}

/// HTTP 5xx.
final class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Dio request cancelled via [CancelToken].
final class RequestCancelledException extends AppException {
  const RequestCancelledException() : super('Request was cancelled.');
}

/// Catch-all for untyped Dio exceptions.
final class UnknownException extends AppException {
  const UnknownException(super.message);
}
