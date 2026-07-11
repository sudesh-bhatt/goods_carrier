import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/env_config.dart';

/// Opens the platform update flow or falls back to the public store listing.
class AppUpdateService {
  Future<void> promptUpdate() async {
    if (Platform.isAndroid) {
      await _promptAndroidUpdate();
      return;
    }

    if (Platform.isIOS) {
      await _promptIosUpdate();
      return;
    }

    _debugLog('No update prompt configured for this platform.');
  }

  Future<void> startUpdate() => promptUpdate();

  Future<void> _promptAndroidUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return;
      }
    } catch (e) {
      _debugLog('In-app update failed; opening Play Store. $e');
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final uri = Uri.https(
      'play.google.com',
      '/store/apps/details',
      {'id': packageInfo.packageName},
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _promptIosUpdate() async {
    final url = EnvConfig.iosAppStoreUrl;
    if (url.isEmpty) {
      _debugLog('IOS_APP_STORE_URL is empty; skipping iOS update prompt.');
      return;
    }

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[AppUpdateService] $message');
    }
  }
}
