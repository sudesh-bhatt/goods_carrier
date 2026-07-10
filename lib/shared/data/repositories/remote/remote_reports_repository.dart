import '../../../domain/entities/reported_trip.dart';
import '../../../domain/repositories/i_reports_repository.dart';
import '../../api/reports/reports_api_client.dart';

class RemoteReportsRepository implements IReportsRepository {
  RemoteReportsRepository({required ReportsApiClient apiClient}) : _api = apiClient;

  final ReportsApiClient _api;

  @override
  Future<String> submitShipmentReport({
    required String shipmentId,
    required String reason,
    String? details,
  }) async {
    final result = await _api.submitReport(
      reportableType: 'shipment',
      reportableId: shipmentId,
      reason: reason,
      description: details,
    );
    return result.id;
  }

  @override
  Future<List<ReportedTrip>> listCustomerReportedTrips({
    String? search,
    int page = 1,
    int perPage = 20,
  }) =>
      _api.listCustomerReportedTrips(
        search: search,
        page: page,
        perPage: perPage,
      );

  @override
  Future<List<ReportedTrip>> listDriverReportedShipments({
    String? search,
    int page = 1,
    int perPage = 20,
  }) =>
      _api.listDriverReportedShipments(
        search: search,
        page: page,
        perPage: perPage,
      );
}
