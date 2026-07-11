import '../../../domain/models/customer_trip_request_result.dart';
import '../reports/reports_api_mapper.dart';

abstract final class CustomerTripApiMapper {
  static CustomerTripRequestResult requestFromJson(Map<String, dynamic> json) {
    return CustomerTripRequestResult(
      id: _readInt(json['id']) ?? 0,
      driverTripId: _readInt(json['driver_trip_id']) ?? 0,
      shipmentId: _readInt(json['shipment_id']),
      status: json['status']?.toString() ?? 'pending',
      note: json['note']?.toString(),
    );
  }

  static String reportIdFromJson(Map<String, dynamic> json) {
    final id = json['report_id']?.toString() ?? json['id']?.toString() ?? '';
    return id.isNotEmpty ? id : 'REP-${DateTime.now().millisecondsSinceEpoch}';
  }

  static Map<String, dynamic> toReportBody({
    required String reasonSlug,
    String? description,
  }) =>
      {
        'reason': ReportsApiMapper.reasonSlugToApiValue(reasonSlug),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      };

  static int? _readInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }
}
