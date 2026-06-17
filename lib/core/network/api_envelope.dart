import 'app_exception.dart';

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
}
