import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around [FirebaseCrashlytics] for app-wide crash reporting.
class CrashlyticsService {
  CrashlyticsService._();

  static final CrashlyticsService instance = CrashlyticsService._();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  Future<void> setUserId(String? userId) async {
    if (userId == null || userId.isEmpty) {
      await _crashlytics.setUserIdentifier('');
      return;
    }
    await _crashlytics.setUserIdentifier(userId);
  }

  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);

  Future<void> log(String message) => _crashlytics.log(message);

  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) {
    if (kDebugMode) {
      debugPrint('[Crashlytics] recordError: $error');
    }
    return _crashlytics.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }
}
