import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';

/// Persists the logged-in user profile for session restore.
class AuthPreferencesStore {
  AuthPreferencesStore(this._prefs);

  static const _kLoggedInUserKey = 'logged_in_user_v1';

  final SharedPreferences _prefs;

  User? loadUser() {
    final raw = _prefs.getString(_kLoggedInUserKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    await _prefs.setString(_kLoggedInUserKey, jsonEncode(user.toJson()));
  }

  Future<void> clearUser() async {
    await _prefs.remove(_kLoggedInUserKey);
  }
}
