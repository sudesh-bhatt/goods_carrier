import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/repositories/i_shipment_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class DriverShipmentRequestsState {
  const DriverShipmentRequestsState({
    required this.all,
    required this.expressed,
    this.isLoading = false,
    this.error,
  });

  /// All pending shipment requests visible to this driver.
  final List<Shipment> all;

  /// IDs the driver has expressed interest in (this session + persisted).
  final Set<String> expressed;

  final bool    isLoading;
  final String? error;

  bool hasExpressed(String shipmentId) => expressed.contains(shipmentId);

  DriverShipmentRequestsState copyWith({
    List<Shipment>? all,
    Set<String>?    expressed,
    bool?           isLoading,
    String?         error,
  }) =>
      DriverShipmentRequestsState(
        all:       all       ?? this.all,
        expressed: expressed ?? this.expressed,
        isLoading: isLoading ?? this.isLoading,
        error:     error,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class DriverShipmentRequestsNotifier
    extends StateNotifier<DriverShipmentRequestsState> {
  DriverShipmentRequestsNotifier(this._repo, this._ref)
      : super(const DriverShipmentRequestsState(all: [], expressed: {})) {
    _load();
  }

  final IShipmentRepository _repo;
  final Ref                 _ref;

  /// Fetches pending shipment requests from the repository.
  ///
  /// In Local mode: filters DummyShipments by pending status.
  /// In Remote mode: GET /shipments/pending?driver_id=... filtered server-side
  /// by vehicle type and location radius.
  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final driverId = _ref.read(authProvider).user?.id;
      final requests = await _repo.getPendingRequests(driverId: driverId);
      state = state.copyWith(isLoading: false, all: requests);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Pull-to-refresh.
  Future<void> refresh() => _load();

  /// Record that this driver has expressed interest in [shipmentId].
  ///
  /// Optimistically adds the ID to [expressed] so the UI updates instantly,
  /// then persists via the repository.  On failure the optimistic entry is
  /// removed and [error] is surfaced.
  Future<void> expressInterest(String shipmentId, {double? quotedPrice}) async {
    final driverId = _ref.read(authProvider).user?.id ?? 'USR-DUMMY';

    // Optimistic update
    state = state.copyWith(
      expressed: {...state.expressed, shipmentId},
    );

    try {
      await _repo.expressInterest(
        shipmentId:  shipmentId,
        driverId:    driverId,
        quotedPrice: quotedPrice,
      );
    } catch (e) {
      // Roll back optimistic update
      final rolled = Set<String>.from(state.expressed)..remove(shipmentId);
      state = state.copyWith(expressed: rolled, error: e.toString());
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final driverShipmentRequestsProvider = StateNotifierProvider<
    DriverShipmentRequestsNotifier, DriverShipmentRequestsState>(
  (ref) => DriverShipmentRequestsNotifier(
    ref.read(shipmentRepositoryProvider),
    ref,
  ),
);
