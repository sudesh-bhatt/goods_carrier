import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/shipment.dart';

/// Persists customer-created shipments in [SharedPreferences].
class ShipmentPreferencesStore {
  ShipmentPreferencesStore(this._prefs);

  static const _kUserShipmentsKey = 'customer_user_shipments_v1';

  final SharedPreferences _prefs;

  Future<List<Shipment>> loadUserShipments() async {
    final raw = _prefs.getString(_kUserShipmentsKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Shipment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveUserShipments(List<Shipment> shipments) async {
    final encoded = jsonEncode(shipments.map((s) => s.toJson()).toList());
    await _prefs.setString(_kUserShipmentsKey, encoded);
  }
}
