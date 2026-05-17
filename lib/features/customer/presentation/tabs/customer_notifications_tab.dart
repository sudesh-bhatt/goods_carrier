import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../providers/customer_notifications_provider.dart';
import '../widgets/customer_notification_card.dart';

/// Notifications tab body.
class CustomerNotificationsTab extends ConsumerStatefulWidget {
  const CustomerNotificationsTab({super.key});

  @override
  ConsumerState<CustomerNotificationsTab> createState() =>
      _CustomerNotificationsTabState();
}

class _CustomerNotificationsTabState
    extends ConsumerState<CustomerNotificationsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final notifications = ref.watch(customerNotificationsProvider);

    if (notifications.isEmpty) {
      return EmptyState(
        headline: l10n.emptyNotifications,
        subtitle: l10n.notificationNoNew,
        fallbackIcon: Icons.notifications_none_rounded,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        return CustomerNotificationCard(
          item: item,
          onTap: () {
            if (!item.isRead) {
              ref
                  .read(customerNotificationsProvider.notifier)
                  .markRead(item.id);
            }
          },
        );
      },
    );
  }
}
