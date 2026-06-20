import 'app_exception.dart';

/// Parsed paginated list payload from the standard API envelope.
class ApiPaginatedPayload {
  const ApiPaginatedPayload({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
  });

  final List<Map<String, dynamic>> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
}

/// Parses the standard Goods Carrier API envelope:
/// `{ "success": bool, "message": string?, "data": T? }`
abstract final class ApiEnvelope {
  static Map<String, dynamic> parseData(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const UnknownException('Unexpected response format');
    }

    final success = raw['success'];
    if (success is bool && !success) {
      final message = raw['message'] as String?;
      throw BadRequestException(message ?? 'Request failed');
    }

    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
    if (data == null) return <String, dynamic>{};
    throw const UnknownException('Unexpected response data');
  }

  static List<Map<String, dynamic>> parseDataList(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const UnknownException('Unexpected response format');
    }

    final success = raw['success'];
    if (success is bool && !success) {
      final message = raw['message'] as String?;
      throw BadRequestException(message ?? 'Request failed');
    }

    final data = raw['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    throw const UnknownException('Unexpected response data');
  }

  /// Parses list payloads that may be a raw array or nested under a key.
  static List<Map<String, dynamic>> parseDataListFlexible(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const UnknownException('Unexpected response format');
    }

    final success = raw['success'];
    if (success is bool && !success) {
      final message = raw['message'] as String?;
      throw BadRequestException(message ?? 'Request failed');
    }

    final data = raw['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      for (final key in [
        'shipments',
        'items',
        'data',
        'records',
        'results',
        'trips',
        'driver_trips',
      ]) {
        final nested = data[key];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    throw const UnknownException('Unexpected response data');
  }

  /// Parses paginated list responses.
  ///
  /// Supports:
  /// - `data: [ ... ]`
  /// - `data: { shipments/items/data: [ ... ], meta/pagination: {...} }`
  static ApiPaginatedPayload parsePaginatedData(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const UnknownException('Unexpected response format');
    }

    final success = raw['success'];
    if (success is bool && !success) {
      final message = raw['message'] as String?;
      throw BadRequestException(message ?? 'Request failed');
    }

    final data = raw['data'];
    if (data is List) {
      final items = data.whereType<Map<String, dynamic>>().toList();
      final meta = raw['meta'] ?? raw['pagination'] ?? raw['page'];
      return ApiPaginatedPayload(
        items: items,
        currentPage: _readInt(meta, 'current_page', fallback: 1),
        lastPage: _readInt(meta, 'last_page', fallback: 1),
        perPage: _readInt(meta, 'per_page', fallback: items.length),
        total: _readInt(meta, 'total', fallback: items.length),
      );
    }

    if (data is Map<String, dynamic>) {
      List<Map<String, dynamic>>? items;
      for (final key in [
        'shipments',
        'items',
        'data',
        'records',
        'results',
        'trips',
        'driver_trips',
      ]) {
        final nested = data[key];
        if (nested is List) {
          items = nested.whereType<Map<String, dynamic>>().toList();
          break;
        }
      }

      if (items != null) {
        final meta = data['meta'] ??
            raw['meta'] ??
            data['pagination'] ??
            raw['pagination'] ??
            data['page'];
        return ApiPaginatedPayload(
          items: items,
          currentPage: _readInt(meta, 'current_page', fallback: 1),
          lastPage: _readInt(meta, 'last_page', fallback: 1),
          perPage: _readInt(meta, 'per_page', fallback: items.length),
          total: _readInt(meta, 'total', fallback: items.length),
        );
      }
    }

    throw const UnknownException('Unexpected response data');
  }

  static int _readInt(dynamic source, String key, {required int fallback}) {
    if (source is! Map<String, dynamic>) return fallback;
    final value = source[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
