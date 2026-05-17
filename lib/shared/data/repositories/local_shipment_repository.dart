import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/dummy/dummy_shipments.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
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
  Future<Shipment> createShipment(Shipment shipment) async {
    await _ensureLoaded();
    await _delay();
    _shipments.removeWhere((s) => s.id == shipment.id);
    _shipments.insert(0, shipment);
    await _persistUserShipments();
    return shipment;
  }

  @override
  Future<Shipment> updateShipment(Shipment shipment) async {
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
  Future<void> cancelShipment(String shipmentId) async {
    await _ensureLoaded();
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx == -1) return;
    _shipments[idx] =
        _shipments[idx].copyWith(status: ShipmentStatus.cancelled);
    if (!_dummyIds.contains(shipmentId)) {
      await _persistUserShipments();
    }
  }

  @override
  Future<void> assignDriver(String shipmentId, String driverId) async {
    await _ensureLoaded();
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx == -1) return;
    _shipments[idx] = _shipments[idx].copyWith(
      status: ShipmentStatus.assigned,
      assignedDriverId: driverId,
    );
    if (!_dummyIds.contains(shipmentId)) {
      await _persistUserShipments();
    }
  }

  // ── Driver operations ────────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getPendingRequests({String? driverId}) async {
    await _ensureLoaded();
    await _delay();
    return _shipments.where((s) => s.isPending).toList();
  }

  @override
  Future<void> expressInterest({
    required String shipmentId,
    required String driverId,
    double? quotedPrice,
  }) async {
    await _ensureLoaded();
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx == -1) return;
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
  }
}
