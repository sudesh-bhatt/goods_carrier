import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/customer/presentation/providers/customer_notifications_provider.dart';
import '../../../features/driver/presentation/providers/driver_notifications_provider.dart';
import '../../domain/entities/notification_item.dart';
import '../widgets/notifications/notifications_list_body.dart';
import 'notifications_scope.dart';

/// Shared notifications tab — same UI; data source depends on [scope].
class NotificationsTab extends ConsumerStatefulWidget {
  const NotificationsTab({super.key, required this.scope});

  final NotificationsScope scope;

  @override
  ConsumerState<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<NotificationsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<NotificationItem> _watchNotifications() {
    return switch (widget.scope) {
      NotificationsScope.customer =>
        ref.watch(customerNotificationsProvider),
      NotificationsScope.driver => ref.watch(driverNotificationsProvider),
    };
  }

  void _markRead(String id) {
    switch (widget.scope) {
      case NotificationsScope.customer:
        ref.read(customerNotificationsProvider.notifier).markRead(id);
      case NotificationsScope.driver:
        ref.read(driverNotificationsProvider.notifier).markRead(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NotificationsListBody(
      notifications: _watchNotifications(),
      onMarkRead: _markRead,
      scope: widget.scope,
    );
  }
}
