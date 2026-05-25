import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/saved_address.dart';

/// Persists customer saved addresses in [SharedPreferences].
class SavedAddressPreferencesStore {
  SavedAddressPreferencesStore(this._prefs);

  static const _kKey = 'customer_saved_addresses_v1';
  static const _kSeededKey = 'customer_saved_addresses_seeded_v1';

  final SharedPreferences _prefs;

  Future<List<SavedAddress>> load() async {
    final raw = _prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) {
      if (!(_prefs.getBool(_kSeededKey) ?? false)) {
        final seeds = SavedAddress.seedDefaults();
        await save(seeds);
        await _prefs.setBool(_kSeededKey, true);
        return seeds;
      }
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => SavedAddress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<SavedAddress> addresses) async {
    final encoded =
        jsonEncode(addresses.map((a) => a.toJson()).toList());
    await _prefs.setString(_kKey, encoded);
  }
}
