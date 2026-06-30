import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/id_prefixes.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../../../../shared/domain/enums/trip_status.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/domain/models/trip_submit_options.dart';
import '../../../../shared/domain/repositories/i_trip_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class DriverTripsState {
  const DriverTripsState({
    required this.trips,
    this.isLoading = false,
    this.error,
  });

  final List<DriverTrip> trips;
  final bool isLoading;
  final String? error;

  DriverTripsState copyWith({
    List<DriverTrip>? trips,
    bool? isLoading,
    String? error,
  }) =>
      DriverTripsState(
        trips: trips ?? this.trips,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  List<DriverTrip> get myTripsList =>
      trips.where((t) => t.status != TripStatus.cancelled).toList();

  List<DriverTrip> get active => trips
      .where(
        (t) =>
            t.status == TripStatus.active ||
            t.status == TripStatus.confirmed,
      )
      .toList();

  List<DriverTrip> get pending => trips
      .where((t) => t.status == TripStatus.pendingConfirmation)
      .toList();

  List<DriverTrip> get completed =>
      trips.where((t) => t.status == TripStatus.completed).toList();

  List<DriverTrip> get history => trips
      .where(
        (t) =>
            t.status == TripStatus.completed ||
            t.status == TripStatus.cancelled,
      )
      .toList();

  DriverTrip? byId(String id) => trips
      .where((t) => t.id == id || t.apiId == id || t.apiResourceId == id)
      .firstOrNull;
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class DriverTripsNotifier extends StateNotifier<DriverTripsState> {
  DriverTripsNotifier(this._repo, this._ref)
      : super(const DriverTripsState(trips: [])) {
    _listenAuth();
    _loadIfReady();
  }

  final ITripRepository _repo;
  final Ref _ref;
  bool _hasLoadedOnce = false;

  String get _driverId => _ref.read(authProvider).user?.id ?? '';

  void _listenAuth() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final id = next.user?.id;
      if (id == null || id.isEmpty) return;
      if (next.sessionPhase != SessionPhase.authenticated) return;

      final userChanged = id != previous?.user?.id;
      final becameAuthenticated =
          previous?.sessionPhase != SessionPhase.authenticated;
      if (!_hasLoadedOnce || userChanged || becameAuthenticated) {
        _load(driverId: id);
      }
    });
  }

  void _loadIfReady() {
    final auth = _ref.read(authProvider);
    final id = auth.user?.id;
    if (id == null ||
        id.isEmpty ||
        auth.sessionPhase != SessionPhase.authenticated) {
      return;
    }
    _load(driverId: id);
  }

  /// Called when the My Trips tab becomes visible.
  Future<void> loadForTab() async {
    final auth = _ref.read(authProvider);
    final id = auth.user?.id;
    if (id == null ||
        id.isEmpty ||
        auth.sessionPhase != SessionPhase.authenticated) {
      return;
    }
    await _load(
      driverId: id,
      showLoadingIndicator: state.trips.isEmpty,
    );
  }

  Future<void> _load({
    String? driverId,
    bool showLoadingIndicator = true,
  }) async {
    final id = driverId ?? _driverId;
    if (id.isEmpty) {
      state = state.copyWith(isLoading: false, trips: []);
      return;
    }
    if (showLoadingIndicator) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }
    try {
      final trips = await _repo.getDriverTrips(id);
      _hasLoadedOnce = true;
      state = state.copyWith(isLoading: false, trips: trips);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<void> refresh() => _load(showLoadingIndicator: false);

  String apiResourceIdFor(String id) => byId(id)?.apiResourceId ?? id;

  DriverTrip? byId(String id) => state.byId(id);

  void upsertTrip(DriverTrip trip) {
    final index = state.trips.indexWhere(
      (t) =>
          t.id == trip.id ||
          (t.apiId != null &&
              (t.apiId == trip.apiId || t.apiId == trip.id)),
    );
    if (index < 0) return;
    final updated = [...state.trips];
    updated[index] = _mergeTripFields(existing: state.trips[index], incoming: trip);
    state = state.copyWith(trips: updated);
  }

  DriverTrip _mergeTripFields({
    required DriverTrip existing,
    required DriverTrip incoming,
  }) =>
      incoming.copyWith(
        driverName: incoming.driverName.isNotEmpty
            ? incoming.driverName
            : existing.driverName,
        driverPhone: incoming.driverPhone ?? existing.driverPhone,
        driverAvatarUrl: incoming.driverAvatarUrl ?? existing.driverAvatarUrl,
        vehicleNumber: incoming.vehicleNumber.isNotEmpty
            ? incoming.vehicleNumber
            : existing.vehicleNumber,
        loadCapacity: incoming.loadCapacity ?? existing.loadCapacity,
        capacityUnit: incoming.capacityUnit ?? existing.capacityUnit,
      );

  Future<bool> acceptTripRequest({
    required String tripId,
    required String requestId,
  }) async {
    state = state.copyWith(error: null);
    try {
      await _repo.acceptTripRequest(tripId: tripId, requestId: requestId);
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return false;
    }
  }

  Future<bool> rejectTripRequest({
    required String tripId,
    required String requestId,
  }) async {
    state = state.copyWith(error: null);
    try {
      await _repo.rejectTripRequest(tripId: tripId, requestId: requestId);
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return false;
    }
  }

  TripSubmitOptions _buildSubmitOptions({
    required int vehicleId,
    required double loadCapacity,
    required String capacityUnit,
    required String fromLocation,
    required String toLocation,
    required String driverCountryCode,
    required String driverPhone,
  }) =>
      TripSubmitOptions(
        vehicleId: vehicleId,
        loadCapacity: loadCapacity,
        capacityUnit: capacityUnit,
        fromLocation: fromLocation,
        toLocation: toLocation,
        driverCountryCode: driverCountryCode,
        driverPhone: driverPhone,
      );

  Future<DriverTrip?> postTrip({
    required String fromCity,
    required String toCity,
    required String fromLocation,
    required String toLocation,
    required DateTime estimatedStartDate,
    required DateTime estimatedEndDate,
    required VehicleType vehicleType,
    required String vehicleNumber,
    required int vehicleId,
    required double loadCapacity,
    required double loadCapacityTons,
    required double estimatedPrice,
    required String capacityUnit,
    required String driverCountryCode,
    required String driverPhone,
    String? driverName,
  }) async {
    final user = _ref.read(authProvider).user!;
    final now = DateTime.now();
    final tempId =
        '${IdPrefixes.driverTrip}${now.millisecondsSinceEpoch % 9000 + 1000}';

    final optimistic = DriverTrip(
      id: tempId,
      driverId: user.id,
      driverName: driverName ?? user.name,
      fromCity: fromLocation.isNotEmpty ? fromLocation : fromCity,
      toCity: toLocation.isNotEmpty ? toLocation : toCity,
      estimatedStartDate: estimatedStartDate,
      estimatedEndDate: estimatedEndDate,
      vehicleCategory: vehicleType,
      vehicleNumber: vehicleNumber,
      loadCapacity: loadCapacity,
      capacityUnit: capacityUnit,
      loadCapacityTons: loadCapacityTons,
      estimatedPrice: estimatedPrice,
      status: TripStatus.active,
    );

    final options = _buildSubmitOptions(
      vehicleId: vehicleId,
      loadCapacity: loadCapacity,
      capacityUnit: capacityUnit,
      fromLocation: fromLocation,
      toLocation: toLocation,
      driverCountryCode: driverCountryCode,
      driverPhone: driverPhone,
    );

    state = state.copyWith(
      isLoading: true,
      trips: [optimistic, ...state.trips],
      error: null,
    );

    try {
      final saved = await _repo.postTrip(optimistic, options: options);
      state = state.copyWith(
        isLoading: false,
        trips: state.trips.map((t) => t.id == tempId ? saved : t).toList(),
      );
      return saved;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        trips: state.trips.where((t) => t.id != tempId).toList(),
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  Future<DriverTrip?> updateTrip(
    DriverTrip updated, {
    required int vehicleId,
    required double loadCapacity,
    required String capacityUnit,
    required String fromLocation,
    required String toLocation,
    required String driverCountryCode,
    required String driverPhone,
  }) async {
    final prev = state.trips;
    state = state.copyWith(
      isLoading: true,
      trips: prev.map((t) => t.id == updated.id ? updated : t).toList(),
      error: null,
    );
    try {
      final options = _buildSubmitOptions(
        vehicleId: vehicleId,
        loadCapacity: loadCapacity,
        capacityUnit: capacityUnit,
        fromLocation: fromLocation,
        toLocation: toLocation,
        driverCountryCode: driverCountryCode,
        driverPhone: driverPhone,
      );
      final saved = await _repo.updateTrip(updated, options: options);
      state = state.copyWith(
        isLoading: false,
        trips: state.trips.map((t) => t.id == saved.id ? saved : t).toList(),
      );
      return saved;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        trips: prev,
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  /// Cancel a trip after the API succeeds.
  /// Returns the server-updated trip, or `null` when the request fails.
  Future<DriverTrip?> cancelTrip(
    String id, {
    required String reason,
    String? otherReason,
  }) async {
    state = state.copyWith(error: null);
    try {
      final updated = await _repo.cancelTrip(
        apiResourceIdFor(id),
        reason: reason,
        otherReason: otherReason,
      );
      state = state.copyWith(
        trips: state.trips
            .where(
              (t) =>
                  t.id != id && t.apiId != id && t.apiResourceId != id,
            )
            .toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return null;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final driverTripsProvider =
    StateNotifierProvider<DriverTripsNotifier, DriverTripsState>(
  (ref) => DriverTripsNotifier(
    ref.read(tripRepositoryProvider),
    ref,
  ),
);
