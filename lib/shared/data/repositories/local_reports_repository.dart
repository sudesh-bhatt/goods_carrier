import '../../../core/dummy/dummy_reported_trips.dart';
import '../../domain/entities/reported_trip.dart';
import '../../domain/repositories/i_reports_repository.dart';

class LocalReportsRepository implements IReportsRepository {
  final List<ReportedTrip> _items = List.of(DummyReportedTrips.list);
  int _counter = 7729;

  @override
  Future<String> submitShipmentReport({
    required String shipmentId,
    required String reason,
    String? details,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _counter += 1;
    return 'REP-$_counter';
  }

  @override
  Future<List<ReportedTrip>> listCustomerReportedTrips() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_items);
  }

  @override
  Future<List<ReportedTrip>> listDriverReportedShipments({String? search}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_items);
  }
}
