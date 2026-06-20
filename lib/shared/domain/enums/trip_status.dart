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

  static TripStatus fromApi(String? raw) {
    if (raw == null || raw.isEmpty) return TripStatus.active;
    final normalized = raw.toLowerCase().replaceAll('-', '_').trim();
    return switch (normalized) {
      'published' || 'active' || 'open' => TripStatus.active,
      'pending' ||
      'pending_confirmation' ||
      'awaiting_confirmation' =>
        TripStatus.pendingConfirmation,
      'confirmed' || 'assigned' => TripStatus.confirmed,
      'completed' || 'delivered' || 'closed' => TripStatus.completed,
      'cancelled' || 'canceled' => TripStatus.cancelled,
      _ => TripStatus.active,
    };
  }
}
