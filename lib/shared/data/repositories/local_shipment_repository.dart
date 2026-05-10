import '../../../core/dummy/dummy_shipments.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../../domain/repositories/i_shipment_repository.dart';

/// In-memory implementation backed by [DummyShipments].
///
/// Used during development (Sessions 1–6) and as a fallback when there is
/// no network connection. All mutations are local-only and lost on restart.
///
/// Replace with [RemoteShipmentRepository] via [shipmentRepositoryProvider]
/// once the backend is live.
class LocalShipmentRepository implements IShipmentRepository {
  /// Mutable in-memory copy of all shipments.
  final List<Shipment> _shipments = List.of(DummyShipments.all);

  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 400));

  // ── Customer operations ──────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getCustomerShipments(String customerId) async {
    await _delay();
    // Dummy data has fixed customer IDs; return all for the dummy user.
    return List.unmodifiable(_shipments);
  }

  @override
  Future<Shipment> createShipment(Shipment shipment) async {
    await _delay();
    _shipments.insert(0, shipment);
    return shipment;
  }

  @override
  Future<void> cancelShipment(String shipmentId) async {
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx != -1) {
      _shipments[idx] =
          _shipments[idx].copyWith(status: ShipmentStatus.cancelled);
    }
  }

  @override
  Future<void> assignDriver(String shipmentId, String driverId) async {
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx != -1) {
      _shipments[idx] = _shipments[idx].copyWith(
        status: ShipmentStatus.assigned,
        assignedDriverId: driverId,
      );
    }
  }

  // ── Driver operations ────────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getPendingRequests({String? driverId}) async {
    await _delay();
    return _shipments.where((s) => s.isPending).toList();
  }

  @override
  Future<void> expressInterest({
    required String shipmentId,
    required String driverId,
    double? quotedPrice,
  }) async {
    await _delay();
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx != -1) {
      final current = _shipments[idx];
      if (!current.interestedDriverIds.contains(driverId)) {
        _shipments[idx] = current.copyWith(
          interestedDriverIds: [...current.interestedDriverIds, driverId],
          status: ShipmentStatus.interestReceived,
        );
      }
    }
  }
}
