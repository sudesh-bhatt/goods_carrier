import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/dummy/dummy_trips.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../shared/data/local/dashboard_preferences_store.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/entities/shipment_masters.dart';
import '../../../../shared/domain/models/customer_dashboard_query.dart';
import '../../../../shared/domain/models/shipment_filter.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class CustomerDashboardState {
  const CustomerDashboardState({
    required this.trips,
    this.vehicleTypes = const [],
    this.selectedVehicleTypeId,
    this.query = const CustomerDashboardQuery(),
    this.isLoading = false,
    this.error,
  });

  final List<DriverTrip> trips;
  final List<ShipmentMasterOption> vehicleTypes;
  final int? selectedVehicleTypeId;
  final CustomerDashboardQuery query;
  final bool isLoading;
  final String? error;

  CustomerDashboardState copyWith({
    List<DriverTrip>? trips,
    List<ShipmentMasterOption>? vehicleTypes,
    int? selectedVehicleTypeId,
    CustomerDashboardQuery? query,
    bool? isLoading,
    String? error,
    bool clearSelectedVehicleTypeId = false,
  }) =>
      CustomerDashboardState(
        trips: trips ?? this.trips,
        vehicleTypes: vehicleTypes ?? this.vehicleTypes,
        selectedVehicleTypeId: clearSelectedVehicleTypeId
            ? null
            : (selectedVehicleTypeId ?? this.selectedVehicleTypeId),
        query: query ?? this.query,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CustomerDashboardNotifier extends StateNotifier<CustomerDashboardState> {
  CustomerDashboardNotifier(this._ref)
      : super(
          CustomerDashboardState(
            trips: const [],
            vehicleTypes: _ref.read(dashboardPreferencesStoreProvider)
                .loadVehicleTypes(),
          ),
        ) {
    _load();
  }

  final Ref _ref;

  DashboardPreferencesStore get _prefsStore =>
      _ref.read(dashboardPreferencesStoreProvider);

  Future<void> _load({
    CustomerDashboardQuery? query,
    bool showLoadingIndicator = true,
  }) async {
    final nextQuery = query ?? state.query;
    if (showLoadingIndicator) {
      state = state.copyWith(isLoading: true, query: nextQuery, error: null);
    } else {
      state = state.copyWith(query: nextQuery, error: null);
    }

    try {
      if (!EnvConfig.useRemoteApi) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        state = state.copyWith(
          isLoading: false,
          trips: List.unmodifiable(DummyTrips.myTrips),
        );
        return;
      }

      final result = await _ref
          .read(customerDashboardApiClientProvider)
          .fetchDashboard(query: nextQuery);

      final visibleTypes = homeDashboardVehicleTypes(result.vehicleTypes);

      if (visibleTypes.isNotEmpty) {
        await _prefsStore.saveVehicleTypes(visibleTypes);
      }

      var selectedId = state.selectedVehicleTypeId;
      if (selectedId != null &&
          !visibleTypes.any((t) => t.id == selectedId)) {
        selectedId = null;
      }

      state = state.copyWith(
        isLoading: false,
        trips: result.trips,
        vehicleTypes: visibleTypes.isNotEmpty
            ? visibleTypes
            : state.vehicleTypes,
        selectedVehicleTypeId: selectedId,
        clearSelectedVehicleTypeId: selectedId == null &&
            state.selectedVehicleTypeId != null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<void> refresh({bool showLoadingIndicator = true}) =>
      _load(showLoadingIndicator: showLoadingIndicator);

  /// Called when the customer home tab becomes visible.
  Future<void> loadForTab() => _load(
        showLoadingIndicator: state.trips.isEmpty,
      );

  Future<void> selectVehicleType(int? id) async {
    if (state.selectedVehicleTypeId == id) return;
    final query = state.query.copyWith(
      vehicleTypeId: id,
      clearVehicleTypeId: id == null,
    );
    state = state.copyWith(
      selectedVehicleTypeId: id,
      clearSelectedVehicleTypeId: id == null,
    );
    await _load(query: query);
  }

  Future<void> applyFilters({
    required String search,
    required ShipmentFilter filter,
    int? vehicleTypeId,
    bool clearVehicleTypeId = false,
  }) async {
    final int? selectedId;
    if (clearVehicleTypeId) {
      selectedId = null;
    } else if (vehicleTypeId != null) {
      selectedId = vehicleTypeId;
    } else if (filter.vehicleTypeId != null) {
      selectedId = filter.vehicleTypeId;
    } else if (filter.vehicleClass != null) {
      selectedId = homeDashboardVehicleTypeIdFor(
        state.vehicleTypes,
        filter.vehicleClass!,
      );
    } else {
      selectedId = null;
    }
    final query = _buildQuery(
      search: search,
      filter: filter,
      vehicleTypeId: selectedId,
    );
    state = state.copyWith(
      selectedVehicleTypeId: selectedId,
      clearSelectedVehicleTypeId: selectedId == null,
    );
    await _load(query: query);
  }

  DriverTrip? byId(String id) => state.trips
      .where((t) => t.id == id || t.apiId == id)
      .firstOrNull;

  String apiResourceIdFor(String id) => byId(id)?.apiResourceId ?? id;

  void markInterested(String tripId) {
    final updated = state.trips.map((trip) {
      if (trip.id != tripId && trip.apiId != tripId) return trip;
      return trip.copyWith(isInterested: true);
    }).toList(growable: false);
    state = state.copyWith(trips: updated);
  }

  CustomerDashboardQuery _buildQuery({
    required String search,
    required ShipmentFilter filter,
    int? vehicleTypeId,
  }) {
    final capacity = filter.apiCapacityKg;

    return CustomerDashboardQuery(
      search: search.trim().isEmpty ? null : search.trim(),
      vehicleTypeId: vehicleTypeId,
      fromCity: filter.fromCity,
      toCity: filter.toCity,
      pickupDate: filter.pickupDate,
      capacityMin: capacity.min,
      capacityMax: capacity.max,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final dashboardPreferencesStoreProvider =
    Provider<DashboardPreferencesStore>((ref) {
  return DashboardPreferencesStore(ref.read(sharedPreferencesProvider));
});

final customerDashboardProvider =
    StateNotifierProvider<CustomerDashboardNotifier, CustomerDashboardState>(
  (ref) => CustomerDashboardNotifier(ref),
);
