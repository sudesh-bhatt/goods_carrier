import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/customer_bottom_nav_bar.dart';
import '../providers/customer_notifications_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/customer_navigation.dart';
import '../widgets/customer_notification_card.dart';
import '../widgets/customer_subscreen_header.dart';

/// Notifications — [Figma `2013:3460`](https://www.figma.com/design/wT5NdNeg7YVPPcq1nY9D2P/Goods-Carrier--Copy-?node-id=2013-3460).
class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final notifications = ref.watch(customerNotificationsProvider);
    final hasUnread = notifications.any((n) => !n.isRead);

    return CustomerLightChrome(
      child: Scaffold(
      backgroundColor: colors.background,
      appBar: CustomerSubscreenHeader(
        title: l10n.notificationsTitle,
        trailing: hasUnread
            ? IconButton(
                onPressed: () => ref
                    .read(customerNotificationsProvider.notifier)
                    .markAllRead(),
                icon: Icon(
                  Icons.done_all_rounded,
                  color: colors.primary,
                ),
                tooltip: l10n.notificationMarkAllRead,
              )
            : SizedBox(width: 32.w),
      ),
      body: SafeArea(
        top: false,
        child: notifications.isEmpty
            ? EmptyState(
                headline: l10n.emptyNotifications,
                subtitle: l10n.notificationNoNew,
                fallbackIcon: Icons.notifications_none_rounded,
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
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
              ),
      ),
      bottomNavigationBar: CustomerBottomNavBar(
        currentTab: CustomerMainTab.notifications,
        onTabSelected: (tab) => navigateCustomerTab(context, tab),
      ),
    ),
    );
  }
}
