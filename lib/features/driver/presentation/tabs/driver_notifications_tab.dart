import 'package:flutter/material.dart';

import '../../../../shared/presentation/notifications/notifications_scope.dart';
import '../../../../shared/presentation/notifications/notifications_tab.dart';

/// Driver notifications tab — shared [NotificationsTab] UI.
class DriverNotificationsTab extends StatelessWidget {
  const DriverNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsTab(scope: NotificationsScope.driver);
  }
}
