import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Firebase Remote Config keys used by the app.
///
/// Keep these separate from backend [AppConfigApiClient] (`GET /api/app/config`).
/// That API owns maintenance / min-version / branding; Remote Config is for
/// lightweight feature flags and copy that can change without a store release.
abstract final class RemoteConfigKeys {
  static const welcomeBannerText = 'welcome_banner_text';
  static const showReferralBanner = 'show_referral_banner';
  static const supportWhatsappNumber = 'support_whatsapp_number';
}

/// Fetches and exposes Remote Config values with in-app defaults.
class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  FirebaseRemoteConfig get _remoteConfig => FirebaseRemoteConfig.instance;

  static const Map<String, dynamic> _defaults = {
    RemoteConfigKeys.welcomeBannerText: '',
    RemoteConfigKeys.showReferralBanner: false,
    RemoteConfigKeys.supportWhatsappNumber: '',
  };

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // Debug: fetch often. Release: 1 hour minimum interval.
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );
    await _remoteConfig.setDefaults(_defaults);

    // Activate last-fetched values immediately, then refresh in background.
    await _remoteConfig.activate();
    unawaited(_fetchAndActivate());
  }

  Future<bool> _fetchAndActivate() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      _debugLog('fetchAndActivate updated=$updated');
      return updated;
    } catch (e, st) {
      _debugLog('fetch failed: $e\n$st');
      return false;
    }
  }

  /// Force a refresh (e.g. pull-to-refresh or after login).
  Future<bool> refresh() => _fetchAndActivate();

  String get welcomeBannerText =>
      _remoteConfig.getString(RemoteConfigKeys.welcomeBannerText);

  bool get showReferralBanner =>
      _remoteConfig.getBool(RemoteConfigKeys.showReferralBanner);

  String get supportWhatsappNumber =>
      _remoteConfig.getString(RemoteConfigKeys.supportWhatsappNumber);

  String getString(String key) => _remoteConfig.getString(key);

  bool getBool(String key) => _remoteConfig.getBool(key);

  int getInt(String key) => _remoteConfig.getInt(key);

  double getDouble(String key) => _remoteConfig.getDouble(key);

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[RemoteConfig] $message');
    }
  }
}
