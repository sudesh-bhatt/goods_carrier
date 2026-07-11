import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/dummy/dummy_shipments.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../../domain/models/customer_shipment_detail.dart';
import '../../domain/models/driver_dashboard_query.dart';
import '../../domain/models/driver_shipment_detail.dart';
import '../../domain/models/shipment_form_prefill.dart';
import '../../domain/models/shipment_submit_options.dart';
import '../../domain/repositories/i_shipment_repository.dart';
import '../local/shipment_preferences_store.dart';

/// In-memory implementation with [SharedPreferences] persistence for user posts.
///
/// Dummy seed data is merged on load; user-created shipments are saved across
/// app restarts.
class LocalShipmentRepository implements IShipmentRepository {
  LocalShipmentRepository(SharedPreferences prefs)
      : _store = ShipmentPreferencesStore(prefs);

  final ShipmentPreferencesStore _store;

  final List<Shipment> _shipments = [];
  late final Set<String> _dummyIds;
  Future<void>? _ready;

  Future<void> _ensureLoaded() {
    _ready ??= _load();
    return _ready!;
  }

  Future<void> _load() async {
    _dummyIds = DummyShipments.all.map((s) => s.id).toSet();
    final saved = await _store.loadUserShipments();

    _shipments
      ..clear()
      ..addAll(saved)
      ..addAll(
        DummyShipments.all.where(
          (d) => !saved.any((s) => s.id == d.id),
        ),
      );
  }

  Future<void> _persistUserShipments() async {
    final userShipments =
        _shipments.where((s) => !_dummyIds.contains(s.id)).toList();
    await _store.saveUserShipments(userShipments);
  }

  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 400));

  // ── Customer operations ──────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getCustomerShipments(String customerId) async {
    await _ensureLoaded();
    await _delay();
    return _shipments
        .where((s) => s.customerId == customerId)
        .toList(growable: false);
  }

  @override
  Future<Shipment> getShipment(String id) async {
    await _ensureLoaded();
    await _delay();
    final shipment = _shipments
        .where((s) => s.id == id || s.apiId == id || s.apiResourceId == id)
        .firstOrNull;
    if (shipment == null) {
      throw StateError('Shipment not found: $id');
    }
    return shipment;
  }

  @override
  Future<CustomerShipmentDetail> getCustomerShipmentDetail(String id) async {
    final shipment = await getShipment(id);
    return CustomerShipmentDetail(
      shipment: shipment,
      paymentSummary: ShipmentPaymentSummary(
        baseFare: shipment.estimatedPrice,
        totalAmount: shipment.estimatedPrice,
      ),
      interestedDrivers: const [],
    );
  }

  @override
  Future<ShipmentFormPrefill> getShipmentForEdit(String id) async {
    await _ensureLoaded();
    await _delay();
    final shipment = _shipments.where((s) => s.id == id).firstOrNull;
    if (shipment == null) {
      throw StateError('Shipment not found: $id');
    }
    return ShipmentFormPrefill(
      shipment: shipment,
      options: ShipmentSubmitOptions(
        goodsTypeId: 1,
        vehicleTypeId: 1,
        estimatedWeight: shipment.goods.weightKg,
        weightUnit: 'kg',
        termsAccepted: true,
      ),
    );
  }

  @override
  Future<Shipment> createShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  }) async {
    await _ensureLoaded();
    await _delay();
    _shipments.removeWhere((s) => s.id == shipment.id);
    _shipments.insert(0, shipment);
    await _persistUserShipments();
    return shipment;
  }

  @override
  Future<Shipment> updateShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  }) async {
    await _ensureLoaded();
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipment.id);
    if (idx == -1) throw StateError('Shipment not found: ${shipment.id}');
    _shipments[idx] = shipment;
    if (!_dummyIds.contains(shipment.id)) {
      await _persistUserShipments();
    }
    return shipment;
  }

  @override
  Future<Shipment> cancelShipment(
    String shipmentId, {
    required String reason,
    String? otherReason,
  }) async {
    await _ensureLoaded();
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx == -1) {
      throw StateError('Shipment not found: $shipmentId');
    }
    _shipments[idx] =
        _shipments[idx].copyWith(status: ShipmentStatus.cancelled);
    if (!_dummyIds.contains(shipmentId)) {
      await _persistUserShipments();
    }
    return _shipments[idx];
  }

  @override
  Future<ShipmentAssignmentResult> assignDriver(
    String shipmentId,
    String driverId,
  ) async {
    await _ensureLoaded();
    await _delay();
    final idx = _shipments.indexWhere(
      (s) => s.id == shipmentId || s.apiId == shipmentId,
    );
    if (idx == -1) {
      return ShipmentAssignmentResult(
        shipmentId: shipmentId,
        driverId: driverId,
        driver: ShipmentInterestedDriver(
          driverId: driverId,
          name: 'Driver',
        ),
      );
    }
    _shipments[idx] = _shipments[idx].copyWith(
      status: ShipmentStatus.assigned,
      assignedDriverId: driverId,
    );
    if (!_dummyIds.contains(shipmentId)) {
      await _persistUserShipments();
    }
    return ShipmentAssignmentResult(
      shipmentId: _shipments[idx].id,
      driverId: driverId,
      driver: ShipmentInterestedDriver(
        driverId: driverId,
        name: 'Driver',
        vehicleName: _shipments[idx].vehicleType.label,
        capacityLabel: _shipments[idx].loadCapacityLabel,
      ),
      status: 'accepted',
    );
  }

  // ── Driver operations ────────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getPendingRequests({
    String? driverId,
    DriverDashboardQuery query = const DriverDashboardQuery(),
  }) async {
    await _ensureLoaded();
    await _delay();
    return _shipments.where((s) => s.isPending).toList();
  }

  @override
  Future<DriverShipmentDetail> getDriverShipmentDetail(String id) async {
    final shipment = await getShipment(id);
    return DriverShipmentDetail(
      shipment: shipment,
      matchesDriverVehicle: true,
      vehicleCapacityLabel: shipment.vehicleType.capacityDisplay,
    );
  }

  @override
  Future<bool> expressInterest({
    required String shipmentId,
    required String driverId,
    required int vehicleId,
    required double offeredPrice,
    required String note,
  }) async {
    await _ensureLoaded();
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx == -1) return false;
    final current = _shipments[idx];
    if (!current.interestedDriverIds.contains(driverId)) {
      _shipments[idx] = current.copyWith(
        interestedDriverIds: [...current.interestedDriverIds, driverId],
        status: ShipmentStatus.interestReceived,
      );
      if (!_dummyIds.contains(shipmentId)) {
        await _persistUserShipments();
      }
    }
    return true;
  }
}
