import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/session_phase.dart';
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

  final List<Shipment> all;
  final Set<String> expressed;
  final bool isLoading;
  final String? error;

  bool hasExpressed(String shipmentId) => expressed.contains(shipmentId);

  DriverShipmentRequestsState copyWith({
    List<Shipment>? all,
    Set<String>? expressed,
    bool? isLoading,
    String? error,
  }) =>
      DriverShipmentRequestsState(
        all: all ?? this.all,
        expressed: expressed ?? this.expressed,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class DriverShipmentRequestsNotifier
    extends StateNotifier<DriverShipmentRequestsState> {
  DriverShipmentRequestsNotifier(this._repo, this._ref)
      : super(const DriverShipmentRequestsState(all: [], expressed: {})) {
    _listenAuth();
    _loadIfReady();
  }

  final IShipmentRepository _repo;
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

  /// Called when the driver home tab becomes visible.
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
      showLoadingIndicator: state.all.isEmpty,
    );
  }

  Future<void> _load({
    String? driverId,
    bool showLoadingIndicator = true,
  }) async {
    if (showLoadingIndicator) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }
    try {
      final requests =
          await _repo.getPendingRequests(driverId: driverId ?? _driverId);
      _hasLoadedOnce = true;
      state = state.copyWith(isLoading: false, all: requests);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<void> refresh() => _load(showLoadingIndicator: false);

  Shipment? byId(String id) => state.all
      .where((s) => s.id == id || s.apiId == id || s.apiResourceId == id)
      .firstOrNull;

  String apiResourceIdFor(String id) => byId(id)?.apiResourceId ?? id;

  void upsertShipment(Shipment shipment) {
    final index = state.all.indexWhere(
      (s) =>
          s.id == shipment.id ||
          (s.apiId != null &&
              (s.apiId == shipment.apiId || s.apiId == shipment.id)),
    );
    if (index < 0) return;
    final updated = [...state.all];
    updated[index] = shipment;
    state = state.copyWith(all: updated);
  }

  void markExpressed(String shipmentId) {
    if (state.expressed.contains(shipmentId)) return;
    state = state.copyWith(expressed: {...state.expressed, shipmentId});
  }

  Future<bool> expressInterest({
    required String shipmentId,
    required int vehicleId,
    required double offeredPrice,
    required String note,
  }) async {
    final driverId = _ref.read(authProvider).user?.id ?? 'USR-DUMMY';
    final apiId = apiResourceIdFor(shipmentId);

    try {
      await _repo.expressInterest(
        shipmentId: apiId,
        driverId: driverId,
        vehicleId: vehicleId,
        offeredPrice: offeredPrice,
        note: note,
      );
      state = state.copyWith(
        expressed: {...state.expressed, shipmentId},
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return false;
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
