import 'package:flutter/material.dart';

import '../../../../shared/presentation/notifications/notifications_scope.dart';
import '../../../../shared/presentation/notifications/notifications_tab.dart';

/// Customer notifications tab — shared [NotificationsTab] UI.
class CustomerNotificationsTab extends StatelessWidget {
  const CustomerNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsTab(scope: NotificationsScope.customer);
  }
}
