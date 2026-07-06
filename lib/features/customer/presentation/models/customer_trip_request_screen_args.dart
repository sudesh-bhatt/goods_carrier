import '../../../../shared/domain/entities/driver_trip.dart';

/// Navigation payload for [CustomerTripRequestScreen].
class CustomerTripRequestScreenArgs {
  const CustomerTripRequestScreenArgs({required this.trip});

  final DriverTrip trip;
}
