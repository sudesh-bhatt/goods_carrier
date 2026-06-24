import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/reported_trip.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/repositories/i_reports_repository.dart';

class CustomerReportedTripsState {
  const CustomerReportedTripsState({
    this.trips = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ReportedTrip> trips;
  final bool isLoading;
  final String? error;

  CustomerReportedTripsState copyWith({
    List<ReportedTrip>? trips,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      CustomerReportedTripsState(
        trips: trips ?? this.trips,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class CustomerReportedTripsNotifier
    extends StateNotifier<CustomerReportedTripsState> {
  CustomerReportedTripsNotifier(this._repo)
      : super(const CustomerReportedTripsState()) {
    load();
  }

  final IReportsRepository _repo;
  final List<ReportedTrip> _localSubmissions = [];

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final remote = await _repo.listCustomerReportedTrips();
      state = CustomerReportedTripsState(
        trips: [..._localSubmissions, ...remote],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<String> submitReport(
    Shipment shipment, {
    required String reason,
    String? details,
  }) async {
    state = state.copyWith(clearError: true);
    try {
      final reportId = await _repo.submitShipmentReport(
        shipmentId: shipment.apiResourceId,
        reason: reason,
        details: details,
      );

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
      _localSubmissions.insert(0, reported);
      state = state.copyWith(trips: [reported, ...state.trips]);
      return reportId;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      rethrow;
    }
  }
}

final customerReportedTripsProvider = StateNotifierProvider<
    CustomerReportedTripsNotifier, CustomerReportedTripsState>(
  (ref) => CustomerReportedTripsNotifier(
    ref.read(reportsRepositoryProvider),
  ),
);
