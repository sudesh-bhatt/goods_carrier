import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/entities/shipment.dart';

/// Navigation payload for [ReportTripScreen].
class ReportTripScreenArgs {
  const ReportTripScreenArgs({
    this.shipment,
    this.driverTrip,
    this.isDriver = false,
  }) : assert(shipment != null || driverTrip != null);

  final Shipment? shipment;
  final DriverTrip? driverTrip;
  final bool isDriver;
}
