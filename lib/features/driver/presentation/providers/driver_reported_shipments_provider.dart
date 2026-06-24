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

  Future<void> load({String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
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
}

final driverReportedShipmentsProvider = StateNotifierProvider<
    DriverReportedShipmentsNotifier, CustomerReportedTripsState>(
  (ref) => DriverReportedShipmentsNotifier(
    ref.read(reportsRepositoryProvider),
  ),
);
