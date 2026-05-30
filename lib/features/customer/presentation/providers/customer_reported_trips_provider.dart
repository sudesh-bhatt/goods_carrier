import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/dummy/dummy_reported_trips.dart';
import '../../../../shared/domain/entities/reported_trip.dart';
import '../../../../shared/domain/entities/shipment.dart';

class CustomerReportedTripsState {
  const CustomerReportedTripsState({
    this.trips = const [],
    this.isLoading = false,
  });

  final List<ReportedTrip> trips;
  final bool isLoading;

  CustomerReportedTripsState copyWith({
    List<ReportedTrip>? trips,
    bool? isLoading,
  }) =>
      CustomerReportedTripsState(
        trips: trips ?? this.trips,
        isLoading: isLoading ?? this.isLoading,
      );
}

class CustomerReportedTripsNotifier
    extends StateNotifier<CustomerReportedTripsState> {
  CustomerReportedTripsNotifier() : super(const CustomerReportedTripsState()) {
    _load();
  }

  int _reportCounter = 7729;

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = CustomerReportedTripsState(trips: DummyReportedTrips.list);
  }

  /// Persists a customer report and returns the generated report id.
  Future<String> submitReport(Shipment shipment) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _reportCounter += 1;
    final reportId = 'REP-$_reportCounter';

    final reported = ReportedTrip(
      id: reportId,
      fromCity: shipment.pickup.city,
      toCity: shipment.drop.city,
      estimatedStartDate: shipment.pickupDateTime,
      estimatedEndDate: shipment.dropDateTime,
      vehicleType: shipment.vehicleType,
      loadCapacityTons: shipment.goods.weightKg / 1000,
      estimatedPrice: shipment.estimatedPrice,
    );

    state = state.copyWith(trips: [reported, ...state.trips]);
    return reportId;
  }
}

final customerReportedTripsProvider = StateNotifierProvider<
    CustomerReportedTripsNotifier, CustomerReportedTripsState>(
  (ref) => CustomerReportedTripsNotifier(),
);
