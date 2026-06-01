import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/navigation/driver_bottom_nav_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/presentation/widgets/customer_light_chrome.dart';
import '../../../customer/presentation/widgets/customer_main_header.dart';
import '../providers/driver_notifications_provider.dart';
import '../providers/driver_shipment_requests_provider.dart';

/// Driver main shell — shared chrome with customer (`1:406`).
class DriverMainShellScreen extends ConsumerWidget {
  const DriverMainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  DriverMainTab get _currentTab =>
      DriverMainTab.values[navigationShell.currentIndex];

  void _onTabSelected(BuildContext context, DriverMainTab tab) {
    if (tab == _currentTab) return;
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      tab.index,
      initialLocation: tab.index == navigationShell.currentIndex,
    );
  }

  String _titleForTab(DriverMainTab tab, AppLocalizations l10n) =>
      switch (tab) {
        DriverMainTab.home => l10n.customerHomeBrandTitle,
        DriverMainTab.myTrips => l10n.driverMyTripsTitle,
        DriverMainTab.notifications => l10n.notificationsTitle,
        DriverMainTab.profile => l10n.customerMyProfile,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final tab = _currentTab;
    final user = ref.watch(authProvider).user;
    final notifications = ref.watch(driverNotificationsProvider);
    final hasUnread = notifications.any((n) => !n.isRead);
    final requestsState = ref.watch(driverShipmentRequestsProvider);
    final showFab = tab == DriverMainTab.myTrips ||
        (tab == DriverMainTab.home &&
            !requestsState.isLoading &&
            requestsState.all.isNotEmpty);

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: colors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerMainHeader(
              title: _titleForTab(tab, l10n),
              userName: user?.name,
              trailing: tab == DriverMainTab.notifications && hasUnread
                  ? IconButton(
                      onPressed: () => ref
                          .read(driverNotificationsProvider.notifier)
                          .markAllRead(),
                      icon: Icon(
                        Icons.done_all_rounded,
                        color: colors.primary,
                      ),
                      tooltip: l10n.notificationMarkAllRead,
                    )
                  : null,
              onProfile: tab == DriverMainTab.profile
                  ? null
                  : () => _onTabSelected(context, DriverMainTab.profile),
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
                    onTap: () => context.push(AppRoutes.postTrip),
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
        bottomNavigationBar: DriverBottomNavBar(
          currentTab: tab,
          onTabSelected: (t) => _onTabSelected(context, t),
        ),
      ),
    );
  }
}

typedef DriverHomeScreen = DriverMainShellScreen;
