import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../domain/entities/notification_item.dart';
import '../../notifications/notifications_scope.dart';
import '../feedback/empty_state.dart';
import 'app_notification_card.dart';
import 'app_notification_tokens.dart';

/// Scrollable notification list — shared by customer & driver.
class NotificationsListBody extends StatelessWidget {
  const NotificationsListBody({
    super.key,
    required this.notifications,
    required this.onMarkRead,
    this.scope = NotificationsScope.driver,
  });

  final List<NotificationItem> notifications;
  final ValueChanged<String> onMarkRead;
  final NotificationsScope scope;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (notifications.isEmpty) {
      return ColoredBox(
        color: AppNotificationTokens.background,
        child: EmptyState(
          headline: l10n.emptyNotifications,
          subtitle: l10n.notificationNoNew,
          fallbackIcon: Icons.notifications_none_rounded,
        ),
      );
    }

    return ColoredBox(
      color: AppNotificationTokens.background,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return AppNotificationCard(
            item: item,
            scope: scope,
            onTap: () {
              if (!item.isRead) onMarkRead(item.id);
            },
          );
        },
      ),
    );
  }
}
