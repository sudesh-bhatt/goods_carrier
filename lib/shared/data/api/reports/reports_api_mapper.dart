import '../../../domain/entities/reported_trip.dart';
import '../../../domain/enums/vehicle_type.dart';

class ReportSubmissionResult {
  const ReportSubmissionResult({
    required this.id,
    this.message,
  });

  final String id;
  final String? message;
}

abstract final class ReportsApiMapper {
  static ReportSubmissionResult fromSubmitJson(Map<String, dynamic> json) {
    final data = json;
    final id = _firstString(data, ['report_id', 'id', 'reference_id']);
    return ReportSubmissionResult(
      id: id.isNotEmpty ? id : 'REP-${DateTime.now().millisecondsSinceEpoch}',
      message: _nullableString(data['message']),
    );
  }

  static ReportedTrip? reportedTripFromJson(Map<String, dynamic> json) {
    final id = _firstString(json, ['report_id', 'id']);
    if (id.isEmpty) return null;

    final capacity = _parseCapacityFields(json);

    return ReportedTrip(
      id: id,
      fromCity: _firstString(json, [
        'from_address',
        'from_city',
        'pickup_city',
        'origin_city',
      ]),
      toCity: _firstString(json, [
        'to_address',
        'to_city',
        'drop_city',
        'destination_city',
      ]),
      estimatedStartDate: _parsePickupDateTime(json),
      estimatedEndDate: _parseOptionalEndDate(json),
      vehicleType: VehicleType.fromApi(
        json['vehicle_type']?.toString() ??
            json['vehicle_type_slug']?.toString(),
      ),
      loadCapacityTons: capacity.tons,
      loadCapacity: capacity.raw > 0 ? capacity.raw : null,
      capacityUnit: capacity.unit,
      estimatedPrice:
          _readDouble(json['estimated_price'] ?? json['price']) ?? 0,
    );
  }

  static DateTime _parsePickupDateTime(Map<String, dynamic> source) {
    final combined = source['pickup_datetime'] ??
        source['pickup_date_time'] ??
        source['pickup_at'];
    if (combined is String && combined.isNotEmpty) {
      return DateTime.parse(combined);
    }

    final date = source['estimated_start_date']?.toString() ??
        source['pickup_date']?.toString();
    final time = source['estimated_start_time']?.toString() ??
        source['pickup_time']?.toString();
    if (date != null && date.isNotEmpty) {
      if (time != null && time.isNotEmpty) {
        final normalizedTime = time.length <= 5 ? '$time:00' : time;
        return DateTime.parse('${date}T$normalizedTime');
      }
      return DateTime.parse(date);
    }

    return DateTime.now();
  }

  static DateTime? _parseOptionalEndDate(Map<String, dynamic> source) {
    final combined = source['drop_datetime'] ?? source['drop_date_time'];
    if (combined is String && combined.isNotEmpty) {
      return DateTime.tryParse(combined);
    }

    final date = source['estimated_end_date']?.toString() ??
        source['drop_date']?.toString();
    if (date == null || date.isEmpty || date.toLowerCase() == 'null') {
      return null;
    }

    final time = source['estimated_end_time']?.toString() ??
        source['drop_time']?.toString();
    if (time != null && time.isNotEmpty) {
      final normalizedTime = time.length <= 5 ? '$time:00' : time;
      return DateTime.tryParse('${date}T$normalizedTime');
    }
    return DateTime.tryParse(date);
  }

  static ({double raw, String unit, double tons}) _parseCapacityFields(
    Map<String, dynamic> json,
  ) {
    final unitField = _normalizeCapacityUnit(
      json['capacity_unit'] as String? ?? json['weight_unit'] as String?,
    );
    final raw = json['load_capacity'] ??
        json['capacity'] ??
        json['load_capacity_tons'] ??
        json['capacity_tons'];

    if (raw is num) {
      final value = raw.toDouble();
      final tons = unitField == 'KG' ? value / 1000 : value;
      return (raw: value, unit: unitField, tons: tons);
    }

    if (raw is String && raw.trim().isNotEmpty) {
      final trimmed = raw.trim();
      final pure = double.tryParse(trimmed);
      if (pure != null) {
        final tons = unitField == 'KG' ? pure / 1000 : pure;
        return (raw: pure, unit: unitField, tons: tons);
      }

      final match = RegExp(
        r'^([\d.]+)\s*(.+)?$',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (match != null) {
        final value = double.tryParse(match.group(1)!) ?? 0;
        final embeddedUnit = match.group(2)?.trim() ?? '';
        final unit = embeddedUnit.isEmpty
            ? unitField
            : _normalizeCapacityUnit(embeddedUnit);
        final tons = unit == 'KG' ? value / 1000 : value;
        return (raw: value, unit: unit, tons: tons);
      }
    }

    return (raw: 0, unit: 'TON', tons: 1);
  }

  static String _normalizeCapacityUnit(String? raw) {
    if (raw == null || raw.isEmpty) return 'TON';
    return raw.toLowerCase() == 'kg' ? 'KG' : 'TON';
  }

  /// Maps UI reason slugs to API-accepted English labels.
  static String reasonSlugToApiValue(String slug) => switch (slug) {
        'spam' => 'Spam or misleading information',
        'incorrect' => 'Incorrect details',
        'fraud' => 'Fraud or suspicious activity',
        'inappropriate' => 'Inappropriate content',
        'notAvailable' => 'Already completed / not available',
        'other' => 'Other',
        _ => slug,
      };

  static Map<String, dynamic> toSubmitBody({
    required String reportableType,
    required String reportableId,
    required String reason,
    String? description,
  }) {
    final parsedId = int.tryParse(reportableId);
    return {
      'reportable_type': reportableType,
      'reportable_id': parsedId ?? reportableId,
      'reason': reasonSlugToApiValue(reason),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    };
  }

  static double? _readDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  static String? _nullableString(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static String _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return '';
  }
}
