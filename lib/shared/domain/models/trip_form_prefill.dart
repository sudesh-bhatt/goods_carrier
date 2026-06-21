import '../entities/driver_trip.dart';
import 'trip_submit_options.dart';

/// Driver trip + API-only fields returned by create/edit/detail endpoints.
class TripFormPrefill {
  const TripFormPrefill({
    required this.trip,
    required this.options,
  });

  final DriverTrip trip;
  final TripSubmitOptions options;
}
