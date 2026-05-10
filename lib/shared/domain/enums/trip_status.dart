enum TripStatus {
  active,
  pendingConfirmation,
  confirmed,
  completed,
  cancelled;

  String get label => switch (this) {
        TripStatus.active              => 'Active',
        TripStatus.pendingConfirmation => 'Pending Confirmation',
        TripStatus.confirmed           => 'Confirmed',
        TripStatus.completed           => 'Completed',
        TripStatus.cancelled           => 'Cancelled',
      };
}
