enum ShipmentStatus {
  pending,
  interestReceived,
  assigned,
  inTransit,
  delivered,
  cancelled;

  /// API snake_case value (Postman collection).
  String get apiValue => switch (this) {
        ShipmentStatus.pending          => 'pending',
        ShipmentStatus.interestReceived => 'interest_received',
        ShipmentStatus.assigned         => 'assigned',
        ShipmentStatus.inTransit        => 'in_transit',
        ShipmentStatus.delivered        => 'delivered',
        ShipmentStatus.cancelled        => 'cancelled',
      };

  static ShipmentStatus fromApi(String? raw) {
    if (raw == null || raw.isEmpty) return ShipmentStatus.pending;
    final normalized = raw.toLowerCase().replaceAll('-', '_');
    return switch (normalized) {
      'published' => ShipmentStatus.pending,
      _ => () {
          for (final status in ShipmentStatus.values) {
            if (status.apiValue == normalized || status.name == normalized) {
              return status;
            }
          }
          return ShipmentStatus.pending;
        }(),
    };
  }

  String get label => switch (this) {
        ShipmentStatus.pending          => 'Pending',
        ShipmentStatus.interestReceived => 'Interest Received',
        ShipmentStatus.assigned         => 'Assigned',
        ShipmentStatus.inTransit        => 'In Transit',
        ShipmentStatus.delivered        => 'Delivered',
        ShipmentStatus.cancelled        => 'Cancelled',
      };
}
