import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/domain/repositories/i_shipment_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class CustomerShipmentsState {
  const CustomerShipmentsState({
    required this.shipments,
    this.isLoading = false,
    this.error,
  });

  final List<Shipment> shipments;
  final bool           isLoading;
  final String?        error;

  CustomerShipmentsState copyWith({
    List<Shipment>? shipments,
    bool?           isLoading,
    String?         error,
  }) =>
      CustomerShipmentsState(
        shipments: shipments ?? this.shipments,
        isLoading: isLoading ?? this.isLoading,
        error:     error,
      );

  List<Shipment> get active    => shipments.where((s) => s.isPending || s.isActive).toList();
  List<Shipment> get completed => shipments.where((s) => s.isCompleted).toList();
  List<Shipment> get cancelled => shipments.where((s) => s.isCancelled).toList();
  List<Shipment> get history   => shipments.where((s) => s.isCompleted || s.isCancelled).toList();
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CustomerShipmentsNotifier
    extends StateNotifier<CustomerShipmentsState> {
  CustomerShipmentsNotifier(this._repo)
      : super(const CustomerShipmentsState(shipments: [])) {
    _load();
  }

  final IShipmentRepository _repo;

  /// Load initial shipment list from the repository.
  ///
  /// In Local mode this returns dummy data instantly; in Remote mode this
  /// makes an authenticated GET to [ApiConstants.customerShipments].
  Future<void> _load({String customerId = 'USR-DUMMY'}) async {
    state = state.copyWith(isLoading: true);
    try {
      final shipments = await _repo.getCustomerShipments(customerId);
      state = state.copyWith(isLoading: false, shipments: shipments);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Pull-to-refresh — re-fetches from the repository.
  Future<void> refresh({String customerId = 'USR-DUMMY'}) =>
      _load(customerId: customerId);

  /// Optimistically inserts [shipment] and persists via the repository.
  Future<void> addShipment(Shipment shipment) async {
    state = state.copyWith(
      isLoading: true,
      shipments: [shipment, ...state.shipments],
    );
    try {
      final saved = await _repo.createShipment(shipment);
      // Replace the optimistic entry with the server-echoed entity
      state = state.copyWith(
        isLoading: false,
        shipments: state.shipments
            .map((s) => s.id == shipment.id ? saved : s)
            .toList(),
      );
    } catch (e) {
      // Roll back optimistic insert on failure
      state = state.copyWith(
        isLoading: false,
        shipments: state.shipments.where((s) => s.id != shipment.id).toList(),
        error: e.toString(),
      );
    }
  }

  /// Cancel a pending shipment — optimistic update + remote call.
  Future<void> cancelShipment(String id) async {
    final prev = state.shipments;
    state = state.copyWith(
      shipments: prev.map((s) {
        return s.id == id ? s.copyWith(status: ShipmentStatus.cancelled) : s;
      }).toList(),
    );
    try {
      await _repo.cancelShipment(id);
    } catch (e) {
      state = state.copyWith(shipments: prev, error: e.toString());
    }
  }

  /// Assign a driver — optimistic update + remote call.
  Future<void> selectDriver(String shipmentId, String driverId) async {
    final prev = state.shipments;
    state = state.copyWith(
      shipments: prev.map((s) {
        return s.id == shipmentId
            ? s.copyWith(
                status:          ShipmentStatus.assigned,
                assignedDriverId: driverId,
              )
            : s;
      }).toList(),
    );
    try {
      await _repo.assignDriver(shipmentId, driverId);
    } catch (e) {
      state = state.copyWith(shipments: prev, error: e.toString());
    }
  }

  /// Synchronous local lookup — used by ShipmentDetailScreen.
  Shipment? byId(String id) =>
      state.shipments.where((s) => s.id == id).firstOrNull;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final customerShipmentsProvider =
    StateNotifierProvider<CustomerShipmentsNotifier, CustomerShipmentsState>(
  (ref) => CustomerShipmentsNotifier(ref.read(shipmentRepositoryProvider)),
);
