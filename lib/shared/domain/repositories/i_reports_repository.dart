import '../entities/reported_trip.dart';

abstract class IReportsRepository {
  Future<String> submitShipmentReport({
    required String shipmentId,
    required String reason,
    String? details,
  });

  Future<List<ReportedTrip>> listCustomerReportedTrips({
    String? search,
    int page = 1,
    int perPage = 20,
  });

  Future<List<ReportedTrip>> listDriverReportedShipments({
    String? search,
    int page = 1,
    int perPage = 20,
  });
}
