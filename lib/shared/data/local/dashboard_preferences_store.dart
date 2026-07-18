import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/shipment_masters.dart';

/// Persists customer dashboard reference data (vehicle types from API).
class DashboardPreferencesStore {
  DashboardPreferencesStore(this._prefs);

  static const _kVehicleTypesKey = 'customer_dashboard_vehicle_types_v1';

  final SharedPreferences _prefs;

  List<ShipmentMasterOption> loadVehicleTypes() {
    final raw = _prefs.getString(_kVehicleTypesKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ShipmentMasterOption.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveVehicleTypes(List<ShipmentMasterOption> types) async {
    final visible = homeDashboardVehicleTypes(types);
    if (visible.isEmpty) {
      await _prefs.remove(_kVehicleTypesKey);
      return;
    }
    final encoded = jsonEncode(visible.map(_vehicleTypeToJson).toList());
    await _prefs.setString(_kVehicleTypesKey, encoded);
  }

  Future<void> clearVehicleTypes() async {
    await _prefs.remove(_kVehicleTypesKey);
  }

  static Map<String, dynamic> _vehicleTypeToJson(ShipmentMasterOption option) =>
      {
        'id': option.id,
        'name': option.name,
        if (option.slug != null) 'slug': option.slug,
        if (option.capacityRange != null)
          'capacity_range': option.capacityRange,
        if (option.iconUrl != null) 'icon_url': option.iconUrl,
        if (option.imageUrl != null) 'image_url': option.imageUrl,
      };
}
