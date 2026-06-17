import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/auth_token_utils.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/onboarding_next_step.dart';

/// Persists logged-in user and onboarding state for session restore.
class AuthPreferencesStore {
  AuthPreferencesStore(this._prefs);

  static const authBearerTokenKey = 'auth_bearer_token_v1';

  static const _kLoggedInUserKey = 'logged_in_user_v1';
  static const _kNextStepKey = 'auth_next_step_v1';
  static const _kPendingProfileImageKey = 'pending_profile_image_v1';

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

  OnboardingNextStep? loadNextStep() {
    final raw = _prefs.getString(_kNextStepKey);
    return OnboardingNextStep.fromApi(raw);
  }

  Future<void> saveUser(User user, {OnboardingNextStep? nextStep}) async {
    await _prefs.setString(_kLoggedInUserKey, jsonEncode(user.toJson()));
    if (nextStep != null) {
      await _prefs.setString(_kNextStepKey, nextStep.apiValue);
    } else {
      await _prefs.remove(_kNextStepKey);
    }
  }

  Future<void> saveNextStep(OnboardingNextStep? nextStep) async {
    if (nextStep == null) {
      await _prefs.remove(_kNextStepKey);
      return;
    }
    await _prefs.setString(_kNextStepKey, nextStep.apiValue);
  }

  Future<void> clearUser() async {
    await _prefs.remove(_kLoggedInUserKey);
    await _prefs.remove(_kNextStepKey);
    await clearAuthBearerToken();
  }

  String? loadAuthBearerToken() => _prefs.getString(authBearerTokenKey);

  Future<void> saveAuthBearerToken(String rawToken) async {
    final bearer = AuthTokenUtils.bearerValue(rawToken);
    if (bearer.isEmpty) return;
    await _prefs.setString(authBearerTokenKey, bearer);
  }

  Future<void> clearAuthBearerToken() async {
    await _prefs.remove(authBearerTokenKey);
  }

  String? loadPendingProfileImage() =>
      _prefs.getString(_kPendingProfileImageKey);

  Future<void> savePendingProfileImage(String localPath) async {
    await _prefs.setString(_kPendingProfileImageKey, localPath);
  }

  Future<void> clearPendingProfileImage() async {
    await _prefs.remove(_kPendingProfileImageKey);
  }
}
