import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs API requests and responses in debug builds.
class LoggingInterceptor extends Interceptor {
  static const _tag = 'API';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('[$_tag] ── REQUEST ──────────────────────────────')
        ..writeln('[$_tag] ${options.method} ${options.uri}');

      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('[$_tag] Query: ${options.queryParameters}');
      }

      buffer.writeln('[$_tag] Headers:\n${_formatJson(_redactHeaders(options.headers))}');

      final body = _formatBody(options.data);
      if (body.isNotEmpty) {
        buffer.writeln('[$_tag] Body:\n$body');
      }

      debugPrint(buffer.toString().trimRight());
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('[$_tag] ── RESPONSE ─────────────────────────────')
        ..writeln(
          '[$_tag] ${response.statusCode} '
          '${response.requestOptions.method} ${response.requestOptions.uri}',
        )
        ..writeln('[$_tag] Body:\n${_formatBody(response.data)}');

      debugPrint(buffer.toString().trimRight());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final status = err.response?.statusCode;
      final buffer = StringBuffer()
        ..writeln('[$_tag] ── ERROR ────────────────────────────────')
        ..writeln(
          '[$_tag] ${status ?? '–'} '
          '${err.requestOptions.method} ${err.requestOptions.uri}',
        )
        ..writeln('[$_tag] Type: ${err.type}')
        ..writeln('[$_tag] Message: ${err.message}');

      final body = err.response?.data;
      if (body != null) {
        buffer.writeln('[$_tag] Body:\n${_formatBody(body)}');
      }

      debugPrint(buffer.toString().trimRight());
    }
    handler.next(err);
  }

  static Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      final lower = key.toLowerCase();
      if (lower.contains('token') && lower != 'authorization') {
        return MapEntry(key, '***REDACTED***');
      }
      return MapEntry(key, value);
    });
  }

  static String _formatBody(dynamic data) {
    if (data == null) return '';

    if (data is FormData) {
      final fields = data.fields
          .map((e) => '  ${e.key}: ${e.value}')
          .join('\n');
      final files = data.files
          .map((e) => '  ${e.key}: <file ${e.value.filename ?? 'unknown'}>')
          .join('\n');
      return [
        if (fields.isNotEmpty) 'fields:\n$fields',
        if (files.isNotEmpty) 'files:\n$files',
      ].join('\n');
    }

    return _formatJson(data);
  }

  static String _formatJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (_) {
      // Fall through to toString.
    }
    return data.toString();
  }
}
