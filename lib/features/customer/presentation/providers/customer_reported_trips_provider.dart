import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/dummy/dummy_reported_trips.dart';
import '../../../../shared/domain/entities/reported_trip.dart';

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

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = CustomerReportedTripsState(trips: DummyReportedTrips.list);
  }
}

final customerReportedTripsProvider = StateNotifierProvider<
    CustomerReportedTripsNotifier, CustomerReportedTripsState>(
  (ref) => CustomerReportedTripsNotifier(),
);
