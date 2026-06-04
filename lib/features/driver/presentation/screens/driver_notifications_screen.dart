import 'package:flutter/material.dart';

import '../../../../shared/presentation/notifications/notifications_scope.dart';
import '../../../../shared/presentation/notifications/notifications_screen.dart';

/// Driver notifications route — shared [NotificationsScreen] UI.
class DriverNotificationsScreen extends StatelessWidget {
  const DriverNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsScreen(scope: NotificationsScope.driver);
  }
}
