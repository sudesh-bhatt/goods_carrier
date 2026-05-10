import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/id_prefixes.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/enums/trip_status.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
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
  final bool             isLoading;
  final String?          error;

  DriverTripsState copyWith({
    List<DriverTrip>? trips,
    bool?             isLoading,
    String?           error,
  }) =>
      DriverTripsState(
        trips:     trips     ?? this.trips,
        isLoading: isLoading ?? this.isLoading,
        error:     error,
      );

  List<DriverTrip> get active    => trips.where((t) =>
      t.status == TripStatus.active || t.status == TripStatus.confirmed).toList();
  List<DriverTrip> get pending   => trips.where((t) =>
      t.status == TripStatus.pendingConfirmation).toList();
  List<DriverTrip> get completed => trips.where((t) =>
      t.status == TripStatus.completed).toList();
  List<DriverTrip> get history   => trips.where((t) =>
      t.status == TripStatus.completed || t.status == TripStatus.cancelled).toList();

  DriverTrip? byId(String id) => trips.where((t) => t.id == id).firstOrNull;
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class DriverTripsNotifier extends StateNotifier<DriverTripsState> {
  DriverTripsNotifier(this._repo, this._ref)
      : super(const DriverTripsState(trips: [])) {
    _load();
  }

  final ITripRepository _repo;
  final Ref             _ref;

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Fetches the authenticated driver's trips from the repository.
  ///
  /// In Local mode returns [DummyTrips.myTrips] after a 400 ms delay.
  /// In Remote mode makes an authenticated GET request.
  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final driverId = _ref.read(authProvider).user?.id ?? 'USR-DUMMY';
      final trips    = await _repo.getDriverTrips(driverId);
      state = state.copyWith(isLoading: false, trips: trips);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Pull-to-refresh.
  Future<void> refresh() => _load();

  /// Post a new available trip with an optimistic insert.
  ///
  /// The trip is prepended to the list immediately so the UI feels instant.
  /// On success the server-echoed entity (with the canonical VB-XXXX id)
  /// replaces the optimistic one.  On failure the optimistic entry is removed
  /// and [error] is surfaced.
  Future<void> postTrip({
    required String      fromCity,
    required String      toCity,
    required DateTime    startDate,
    required VehicleType vehicleType,
    required String      vehicleNumber,
    required double      loadCapacityTons,
    required double      estimatedPrice,
  }) async {
    final user  = _ref.read(authProvider).user!;
    final now   = DateTime.now();
    final tempId = '${IdPrefixes.driverTrip}${now.millisecondsSinceEpoch % 9000 + 1000}';

    final optimistic = DriverTrip(
      id:                 tempId,
      driverId:           user.id,
      driverName:         user.name,
      fromCity:           fromCity,
      toCity:             toCity,
      estimatedStartDate: startDate,
      estimatedEndDate:   startDate.add(const Duration(days: 3)),
      vehicleCategory:    vehicleType,
      vehicleNumber:      vehicleNumber,
      loadCapacityTons:   loadCapacityTons,
      estimatedPrice:     estimatedPrice,
      status:             TripStatus.active,
    );

    // Optimistic insert
    state = state.copyWith(
      isLoading: true,
      trips: [optimistic, ...state.trips],
    );

    try {
      final saved = await _repo.postTrip(optimistic);
      // Replace optimistic entry with server-echoed entity
      state = state.copyWith(
        isLoading: false,
        trips: state.trips
            .map((t) => t.id == tempId ? saved : t)
            .toList(),
      );
    } catch (e) {
      // Roll back optimistic insert
      state = state.copyWith(
        isLoading: false,
        trips: state.trips.where((t) => t.id != tempId).toList(),
        error: e.toString(),
      );
    }
  }

  /// Cancel a trip — optimistic update with rollback on error.
  Future<void> cancelTrip(String id) async {
    final prev = state.trips;
    state = state.copyWith(
      trips: prev.map((t) {
        return t.id == id ? t.copyWith(status: TripStatus.cancelled) : t;
      }).toList(),
    );
    try {
      await _repo.cancelTrip(id);
    } catch (e) {
      state = state.copyWith(trips: prev, error: e.toString());
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
