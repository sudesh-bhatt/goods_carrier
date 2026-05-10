enum ShipmentStatus {
  pending,
  interestReceived,
  assigned,
  inTransit,
  delivered,
  cancelled;

  String get label => switch (this) {
        ShipmentStatus.pending          => 'Pending',
        ShipmentStatus.interestReceived => 'Interest Received',
        ShipmentStatus.assigned         => 'Assigned',
        ShipmentStatus.inTransit        => 'In Transit',
        ShipmentStatus.delivered        => 'Delivered',
        ShipmentStatus.cancelled        => 'Cancelled',
      };
}
