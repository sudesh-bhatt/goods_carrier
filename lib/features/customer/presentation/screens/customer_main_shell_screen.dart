import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/navigation/customer_bottom_nav_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_notifications_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/customer_main_header.dart';

/// Customer main shell — one scaffold; [navigationShell] swaps tab bodies only.
class CustomerMainShellScreen extends ConsumerWidget {
  const CustomerMainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  CustomerMainTab get _currentTab =>
      CustomerMainTab.values[navigationShell.currentIndex];

  void _onTabSelected(BuildContext context, CustomerMainTab tab) {
    if (tab == _currentTab) return;
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      tab.index,
      initialLocation: tab.index == navigationShell.currentIndex,
    );
  }

  String _titleForTab(CustomerMainTab tab, AppLocalizations l10n) =>
      switch (tab) {
        CustomerMainTab.home => l10n.customerHomeBrandTitle,
        CustomerMainTab.shipments => l10n.customerMyShipment,
        CustomerMainTab.notifications => l10n.notificationsTitle,
        CustomerMainTab.profile => l10n.customerMyProfile,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final tab = _currentTab;
    final user = ref.watch(authProvider).user;
    final unreadCount = ref.watch(customerUnreadCountProvider);
    final notifications = ref.watch(customerNotificationsProvider);
    final hasUnread = notifications.any((n) => !n.isRead);

    final showFab =
        tab == CustomerMainTab.home || tab == CustomerMainTab.shipments;

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: colors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerMainHeader(
              title: _titleForTab(tab, l10n),
              unreadCount: unreadCount,
              userName: user?.name,
              trailing: tab == CustomerMainTab.notifications && hasUnread
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
                  : null,
              onNotifications: tab == CustomerMainTab.notifications
                  ? null
                  : () => _onTabSelected(
                        context,
                        CustomerMainTab.notifications,
                      ),
              onProfile: tab == CustomerMainTab.profile
                  ? null
                  : () => _onTabSelected(context, CustomerMainTab.profile),
            ),
            Expanded(child: navigationShell),
          ],
        ),
        floatingActionButton: showFab
            ? Padding(
                padding: EdgeInsets.only(bottom: 12.h, right: 4.w),
                child: Material(
                  elevation: 6,
                  shadowColor: colors.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(18.r),
                  color: colors.primary,
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.postShipment),
                    borderRadius: BorderRadius.circular(18.r),
                    child: SizedBox(
                      width: 64.w,
                      height: 64.w,
                      child: Icon(
                        Icons.add_rounded,
                        color: colors.onPrimary,
                        size: 28.w,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: CustomerBottomNavBar(
          currentTab: tab,
          onTabSelected: (t) => _onTabSelected(context, t),
        ),
      ),
    );
  }
}

/// Maps shell branch index ↔ tab (order must match [app_router] branches).
extension CustomerMainTabIndex on CustomerMainTab {
  static CustomerMainTab fromIndex(int index) => CustomerMainTab.values[index];
}

/// Back-compat alias.
typedef CustomerHomeScreen = CustomerMainShellScreen;
