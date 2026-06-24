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
    final id = _firstString(data, ['id', 'report_id', 'reference_id']);
    return ReportSubmissionResult(
      id: id.isNotEmpty ? id : 'REP-${DateTime.now().millisecondsSinceEpoch}',
      message: _nullableString(data['message']),
    );
  }

  static ReportedTrip? reportedTripFromJson(Map<String, dynamic> json) {
    final id = _firstString(json, ['id', 'report_id']);
    if (id.isEmpty) return null;

    return ReportedTrip(
      id: id,
      fromCity: _firstString(json, ['from_city', 'pickup_city', 'origin_city']),
      toCity: _firstString(json, ['to_city', 'drop_city', 'destination_city']),
      estimatedStartDate: DateTime.tryParse(
            json['pickup_date']?.toString() ??
                json['estimated_start_date']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      estimatedEndDate: DateTime.tryParse(
            json['drop_date']?.toString() ??
                json['estimated_end_date']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      vehicleType: VehicleType.fromApi(
        json['vehicle_type']?.toString() ?? json['vehicle_type_slug']?.toString(),
      ),
      loadCapacityTons: _readDouble(json['capacity'] ?? json['load_capacity']) ??
          _readDouble(json['capacity_tons']) ??
          1,
      estimatedPrice: _readDouble(json['estimated_price'] ?? json['price']) ?? 0,
    );
  }

  static Map<String, dynamic> toSubmitBody({
    required String referenceType,
    required String referenceId,
    required String reason,
    String? details,
  }) =>
      {
        'reference_type': referenceType,
        'reference_id': referenceId,
        'reason': reason,
        if (details != null && details.trim().isNotEmpty) 'details': details.trim(),
      };

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
