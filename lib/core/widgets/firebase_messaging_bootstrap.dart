import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_providers.dart';
import '../../features/settings/presentation/providers/push_notifications_provider.dart';

/// Syncs FCM with the push-enabled preference.
///
/// Token fetch + permission run on [SplashScreen] before API calls so
/// `X-FCM-Token` is available on the first request headers.
class FirebaseMessagingBootstrap extends ConsumerWidget {
  const FirebaseMessagingBootstrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(pushNotificationsProvider, (previous, next) async {
      final fcm = ref.read(fcmServiceProvider);
      if (next) {
        await fcm.requestPermission();
        await fcm.initialize(requestPermission: false);
      } else {
        await fcm.deleteToken();
      }
    });

    return child;
  }
}
