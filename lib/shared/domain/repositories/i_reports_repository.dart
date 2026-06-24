import '../entities/reported_trip.dart';

abstract class IReportsRepository {
  Future<String> submitShipmentReport({
    required String shipmentId,
    required String reason,
    String? details,
  });

  Future<List<ReportedTrip>> listCustomerReportedTrips();

  Future<List<ReportedTrip>> listDriverReportedShipments({String? search});
}
