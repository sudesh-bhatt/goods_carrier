import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/enums/trip_status.dart';

/// Figma My Trips list status pill — node `1:3967`.
enum DriverTripListBadge {
  published,
  expired,
  draft,
}

extension DriverTripListBadgeX on DriverTripListBadge {
  Color get background => switch (this) {
        DriverTripListBadge.published => const Color(0xFFDCFCE7),
        DriverTripListBadge.expired => const Color(0xFFE0E0E0),
        DriverTripListBadge.draft => const Color(0xFFFFDAD6),
      };

  Color get foreground => switch (this) {
        DriverTripListBadge.published => const Color(0xFF15803D),
        DriverTripListBadge.expired => const Color(0xFF484848),
        DriverTripListBadge.draft => const Color(0xFF93000A),
      };
}

DriverTripListBadge listBadgeFor(DriverTrip trip) {
  switch (trip.status) {
    case TripStatus.completed:
    case TripStatus.cancelled:
      return DriverTripListBadge.expired;
    case TripStatus.pendingConfirmation:
      return DriverTripListBadge.draft;
    case TripStatus.active:
    case TripStatus.confirmed:
      return DriverTripListBadge.published;
  }
}
