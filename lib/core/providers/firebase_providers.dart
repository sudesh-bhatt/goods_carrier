import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/crashlytics_service.dart';
import '../services/fcm_service.dart';
import '../services/remote_config_service.dart';

final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  return CrashlyticsService.instance;
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService.instance;
});

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService.instance;
});
