import '../entities/driver_trip.dart';

/// Customer interest/request on a driver trip.
class DriverTripRequest {
  const DriverTripRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.phone,
    this.status,
    this.quotedPrice,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String? phone;
  final String? status;
  final double? quotedPrice;

  bool get isPending {
    final normalized = status?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) return true;
    return normalized == 'pending' ||
        normalized == 'requested' ||
        normalized == 'interest_received';
  }
}

/// Detail payload from `GET /api/driver/trips/{id}` (+ optional requests list).
class DriverTripDetail {
  const DriverTripDetail({
    required this.trip,
    this.requests = const [],
  });

  final DriverTrip trip;
  final List<DriverTripRequest> requests;
}
