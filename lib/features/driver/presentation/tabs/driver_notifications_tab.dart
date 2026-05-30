import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/notifications/notification_tile.dart';
import '../providers/driver_notifications_provider.dart';

/// Driver notifications tab body.
class DriverNotificationsTab extends ConsumerStatefulWidget {
  const DriverNotificationsTab({super.key});

  @override
  ConsumerState<DriverNotificationsTab> createState() =>
      _DriverNotificationsTabState();
}

class _DriverNotificationsTabState extends ConsumerState<DriverNotificationsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = context.l10n;
    final colors = context.colors;
    final notifications = ref.watch(driverNotificationsProvider);

    if (notifications.isEmpty) {
      return EmptyState(
        headline: l10n.emptyNotifications,
        subtitle: l10n.notificationNoNew,
        fallbackIcon: Icons.notifications_none_rounded,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colors.divider,
      ),
      itemBuilder: (context, index) {
        final item = notifications[index];
        return NotificationTile(
          item: item,
          onMarkRead: () => ref
              .read(driverNotificationsProvider.notifier)
              .markRead(item.id),
        );
      },
    );
  }
}
