import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/domain/models/shipment_submit_options.dart';
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
  CustomerShipmentsNotifier(this._repo, this._ref)
      : super(const CustomerShipmentsState(shipments: [])) {
    _listenAuth();
    _loadIfReady();
  }

  final IShipmentRepository _repo;
  final Ref _ref;
  bool _hasLoadedOnce = false;

  String get _customerId => _ref.read(authProvider).user?.id ?? '';

  void _listenAuth() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final id = next.user?.id;
      if (id == null || id.isEmpty) return;
      if (next.sessionPhase != SessionPhase.authenticated) return;

      final userChanged = id != previous?.user?.id;
      final becameAuthenticated =
          previous?.sessionPhase != SessionPhase.authenticated;
      if (!_hasLoadedOnce || userChanged || becameAuthenticated) {
        _load(customerId: id);
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
    _load(customerId: id);
  }

  /// Called when the My Shipment tab becomes visible — always re-fetches from API.
  Future<void> loadForTab() async {
    final auth = _ref.read(authProvider);
    final id = auth.user?.id;
    if (id == null ||
        id.isEmpty ||
        auth.sessionPhase != SessionPhase.authenticated) {
      return;
    }
    await _load(
      customerId: id,
      showLoadingIndicator: state.shipments.isEmpty,
    );
  }

  /// Load initial shipment list from the repository.
  ///
  /// In Local mode this returns dummy data instantly; in Remote mode this
  /// makes an authenticated GET to [ApiConstants.customerShipments].
  Future<void> _load({
    String? customerId,
    bool showLoadingIndicator = true,
  }) async {
    final id = customerId ?? _customerId;
    if (id.isEmpty) {
      state = state.copyWith(isLoading: false, shipments: []);
      return;
    }
    if (showLoadingIndicator) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }
    try {
      final shipments = await _repo.getCustomerShipments(id);
      _hasLoadedOnce = true;
      state = state.copyWith(isLoading: false, shipments: shipments);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  /// Pull-to-refresh — re-fetches from the repository.
  Future<void> refresh() => _load(showLoadingIndicator: false);

  /// Replaces an existing shipment (edit flow).
  Future<void> updateShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  }) async {
    final prev = state.shipments;
    state = state.copyWith(
      isLoading: true,
      shipments: prev
          .map((s) => s.id == shipment.id ? shipment : s)
          .toList(),
    );
    try {
      final saved = await _repo.updateShipment(shipment, options: options);
      state = state.copyWith(
        isLoading: false,
        shipments: state.shipments
            .map((s) => s.id == shipment.id ? saved : s)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        shipments: prev,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  /// Optimistically inserts [shipment] and persists via the repository.
  /// Returns the server-echoed entity on success.
  Future<Shipment?> addShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  }) async {
    state = state.copyWith(
      isLoading: true,
      shipments: [shipment, ...state.shipments],
    );
    try {
      final saved = await _repo.createShipment(shipment, options: options);
      final withoutOptimistic =
          state.shipments.where((s) => s.id != shipment.id).toList();
      state = state.copyWith(
        isLoading: false,
        shipments: [saved, ...withoutOptimistic],
      );
      return saved;
    } catch (e) {
      // Roll back optimistic insert on failure
      state = state.copyWith(
        isLoading: false,
        shipments: state.shipments.where((s) => s.id != shipment.id).toList(),
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  /// Cancel a pending shipment after the API succeeds.
  /// Returns the server-updated shipment, or `null` when the request fails.
  Future<Shipment?> cancelShipment(
    String id, {
    required String reason,
    String? otherReason,
  }) async {
    state = state.copyWith(error: null);
    try {
      final updated = await _repo.cancelShipment(
        apiResourceIdFor(id),
        reason: reason,
        otherReason: otherReason,
      );
      state = state.copyWith(
        shipments: state.shipments
            .where(
              (s) =>
                  s.id != id && s.apiId != id && s.apiResourceId != id,
            )
            .toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return null;
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
      await _repo.assignDriver(
        apiResourceIdFor(shipmentId),
        driverId,
      );
    } catch (e) {
      state = state.copyWith(
        shipments: prev,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }
  Shipment? byId(String id) =>
      state.shipments.where((s) => s.id == id || s.apiId == id).firstOrNull;

  /// Backend path id for `/api/customer/shipments/{id}` — numeric when available.
  String apiResourceIdFor(String id) => byId(id)?.apiResourceId ?? id;

  void upsertShipment(Shipment shipment) {
    final index = state.shipments.indexWhere(
      (s) =>
          s.id == shipment.id ||
          (s.apiId != null &&
              (s.apiId == shipment.apiId || s.apiId == shipment.id)),
    );
    if (index < 0) return;
    final updated = [...state.shipments];
    updated[index] = shipment;
    state = state.copyWith(shipments: updated);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final customerShipmentsProvider =
    StateNotifierProvider<CustomerShipmentsNotifier, CustomerShipmentsState>(
  (ref) => CustomerShipmentsNotifier(
    ref.read(shipmentRepositoryProvider),
    ref,
  ),
);
