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
  Future<List<ReportedTrip>> listCustomerReportedTrips({
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_filter(_items, search));
  }

  @override
  Future<List<ReportedTrip>> listDriverReportedShipments({
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_filter(_items, search));
  }

  List<ReportedTrip> _filter(List<ReportedTrip> source, String? search) {
    final query = search?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return source;
    return source.where((t) {
      final haystack = [
        t.id,
        t.fromCity,
        t.toCity,
        t.vehicleType.label,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }
}
