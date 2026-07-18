import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'fcm_service.dart';
import 'remote_config_service.dart';

/// Initializes Firebase and product SDKs before [runApp].
///
/// Order: Core → Crashlytics handlers → FCM background handler → Remote Config.
Future<void> bootstrapFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Disable Crashlytics collection in debug to avoid noise; enable for release.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await RemoteConfigService.instance.initialize();
}
