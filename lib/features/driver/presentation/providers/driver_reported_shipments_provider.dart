import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../customer/presentation/providers/customer_reported_trips_provider.dart';
import '../../../../shared/domain/repositories/i_reports_repository.dart';

class DriverReportedShipmentsNotifier
    extends StateNotifier<CustomerReportedTripsState> {
  DriverReportedShipmentsNotifier(this._repo)
      : super(const CustomerReportedTripsState()) {
    load();
  }

  final IReportsRepository _repo;

  Future<void> load({String? search, bool showLoadingIndicator = true}) async {
    final nextSearch = search;
    final shouldShowLoader =
        showLoadingIndicator && state.trips.isEmpty && (nextSearch == null || nextSearch.isEmpty);
    if (shouldShowLoader) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }
    try {
      final trips = await _repo.listDriverReportedShipments(search: search);
      state = CustomerReportedTripsState(trips: trips);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<void> refresh({String? search}) =>
      load(search: search, showLoadingIndicator: false);
}

final driverReportedShipmentsProvider = StateNotifierProvider<
    DriverReportedShipmentsNotifier, CustomerReportedTripsState>(
  (ref) => DriverReportedShipmentsNotifier(
    ref.read(reportsRepositoryProvider),
  ),
);
