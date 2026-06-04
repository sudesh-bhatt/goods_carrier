import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/theme_ext.dart';
import '../../../features/customer/presentation/providers/customer_notifications_provider.dart';
import '../../../features/driver/presentation/providers/driver_notifications_provider.dart';
import '../../domain/entities/notification_item.dart';
import '../widgets/notifications/app_notifications_header.dart';
import '../widgets/notifications/app_notification_tokens.dart';
import '../widgets/notifications/notifications_list_body.dart';
import 'notifications_scope.dart';

/// Full-screen notifications — shared chrome for customer & driver routes.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key, required this.scope});

  final NotificationsScope scope;

  List<NotificationItem> _watchNotifications(WidgetRef ref) {
    return switch (scope) {
      NotificationsScope.customer =>
        ref.watch(customerNotificationsProvider),
      NotificationsScope.driver => ref.watch(driverNotificationsProvider),
    };
  }

  void _markAllRead(WidgetRef ref) {
    switch (scope) {
      case NotificationsScope.customer:
        ref.read(customerNotificationsProvider.notifier).markAllRead();
      case NotificationsScope.driver:
        ref.read(driverNotificationsProvider.notifier).markAllRead();
    }
  }

  void _markRead(WidgetRef ref, String id) {
    switch (scope) {
      case NotificationsScope.customer:
        ref.read(customerNotificationsProvider.notifier).markRead(id);
      case NotificationsScope.driver:
        ref.read(driverNotificationsProvider.notifier).markRead(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifications = _watchNotifications(ref);
    final hasUnread = notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: AppNotificationTokens.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppNotificationsHeader(
            title: l10n.notificationsTitle,
            showMarkAllRead: hasUnread,
            onMarkAllRead:
                hasUnread ? () => _markAllRead(ref) : null,
          ),
          Expanded(
            child: NotificationsListBody(
              notifications: notifications,
              onMarkRead: (id) => _markRead(ref, id),
            ),
          ),
        ],
      ),
    );
  }
}
