/// Result of `POST /api/customer/trips/{id}/requests`.
class CustomerTripRequestResult {
  const CustomerTripRequestResult({
    required this.id,
    required this.driverTripId,
    required this.status,
    this.shipmentId,
    this.note,
  });

  final int id;
  final int driverTripId;
  final int? shipmentId;
  final String status;
  final String? note;
}
