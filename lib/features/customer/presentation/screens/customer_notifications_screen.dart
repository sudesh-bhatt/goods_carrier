import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/notifications/notification_tile.dart';
import '../providers/customer_notifications_provider.dart';

/// Customer notification list screen.
///
/// Unread items appear with an accent background per [NotificationTile].
/// "Mark all as read" AppBar action calls [CustomerNotificationsNotifier.markAllRead].
class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors        = context.colors;
    final notifications = ref.watch(customerNotificationsProvider);
    final hasUnread     = notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: context.l10n.notificationsTitle,
        actions: [
          if (hasUnread)
            AppBarAction(
              icon: Icons.done_all_rounded,
              onTap: () =>
                  ref.read(customerNotificationsProvider.notifier).markAllRead(),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? EmptyState(
                headline: context.l10n.emptyNotifications,
                subtitle: context.l10n.notificationNoNew,
                fallbackIcon: Icons.notifications_none_rounded,
              )
            : ListView.separated(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensions.base.h,
                ),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: AppDimensions.screenPadding.w + AppDimensions.iconBase.w + AppDimensions.sm.w,
                  color: colors.divider,
                ),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return NotificationTile(
                    item:       item,
                    onMarkRead: () => ref
                        .read(customerNotificationsProvider.notifier)
                        .markRead(item.id),
                  );
                },
              ),
      ),
    );
  }
}
