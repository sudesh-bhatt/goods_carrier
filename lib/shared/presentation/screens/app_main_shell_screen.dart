import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/extensions/size_ext.dart';
import '../../../core/extensions/theme_ext.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/customer/presentation/providers/customer_dashboard_provider.dart';
import '../../../features/customer/presentation/providers/customer_notifications_provider.dart';
import '../../../features/customer/presentation/providers/customer_shipments_provider.dart';
import '../../../features/customer/presentation/widgets/customer_light_chrome.dart';
import '../../../features/customer/presentation/widgets/customer_main_header.dart';
import '../../../features/driver/presentation/providers/driver_shipment_requests_provider.dart';
import '../../../features/driver/presentation/providers/driver_trips_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/enums/user_role.dart';
import '../widgets/navigation/app_bottom_nav_bar.dart';
import '../widgets/navigation/app_main_tab.dart';
import '../widgets/notifications/app_notification_tokens.dart';
import '../widgets/notifications/app_notifications_header.dart';

/// Customer and driver main shell — one scaffold; [navigationShell] swaps tab bodies.
class AppMainShellScreen extends ConsumerWidget {
  const AppMainShellScreen({
    super.key,
    required this.role,
    required this.navigationShell,
  });

  final UserRole role;
  final StatefulNavigationShell navigationShell;

  AppMainTab get _currentTab =>
      AppMainTab.values[navigationShell.currentIndex];

  void _onTabSelected(BuildContext context, WidgetRef ref, AppMainTab tab) {
    if (tab == _currentTab) return;
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      tab.index,
      initialLocation: tab.index == navigationShell.currentIndex,
    );
    if (role == UserRole.customer) {
      if (tab == AppMainTab.home) {
        ref.read(customerDashboardProvider.notifier).loadForTab();
      } else if (tab == AppMainTab.listings) {
        ref.read(customerShipmentsProvider.notifier).loadForTab();
      }
    }
    if (tab == AppMainTab.notifications) {
      switch (role) {
        case UserRole.customer:
          ref.read(customerNotificationsProvider.notifier).loadForTab();
        case UserRole.driver:
          ref.read(driverNotificationsProvider.notifier).loadForTab();
      }
    }
    if (role == UserRole.driver) {
      if (tab == AppMainTab.listings) {
        ref.read(driverTripsProvider.notifier).loadForTab();
      } else if (tab == AppMainTab.home) {
        ref.read(driverShipmentRequestsProvider.notifier).loadForTab();
      } else if (tab == AppMainTab.profile && EnvConfig.useRemoteApi) {
        ref.read(authProvider.notifier).refreshDriverProfile();
      }
    }
  }

  String _titleForTab(
    AppMainTab tab,
    AppLocalizations l10n,
    AppBranding branding,
  ) =>
      switch (tab) {
        AppMainTab.home => branding.appName(l10n),
        AppMainTab.listings => switch (role) {
            UserRole.customer => l10n.customerMyShipment,
            UserRole.driver => l10n.driverMyTripsTitle,
          },
        AppMainTab.notifications => l10n.notificationsTitle,
        AppMainTab.profile => l10n.customerMyProfile,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final branding = AppBranding.of(ref);
    final tab = _currentTab;
    final user = ref.watch(authProvider).user;

    final hasUnread = switch (role) {
      UserRole.customer => ref.watch(customerNotificationsProvider).unreadCount > 0,
      UserRole.driver => ref.watch(driverNotificationsProvider).unreadCount > 0,
    };

    final showFab = _showFab(ref, tab);
    final fabRoute =
        role == UserRole.customer ? AppRoutes.postShipment : AppRoutes.postTrip;

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: tab == AppMainTab.notifications
            ? AppNotificationTokens.background
            : colors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (tab == AppMainTab.notifications)
              AppNotificationsHeader(
                title: l10n.notificationsTitle,
                showMarkAllRead: hasUnread,
                onMarkAllRead: hasUnread ? () => _markAllRead(ref) : null,
              )
            else
              CustomerMainHeader(
                title: _titleForTab(tab, l10n, branding),
                userInitials: user?.initials ?? '?',
                profileImageUrl: user?.profileImageUrl,
                onProfile: tab == AppMainTab.profile
                    ? null
                    : () => _onTabSelected(context, ref, AppMainTab.profile),
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
                    onTap: () => context.push(fabRoute),
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
        bottomNavigationBar: AppBottomNavBar(
          role: role,
          currentTab: tab,
          onTabSelected: (t) => _onTabSelected(context, ref, t),
        ),
      ),
    );
  }

  void _markAllRead(WidgetRef ref) {
    switch (role) {
      case UserRole.customer:
        ref.read(customerNotificationsProvider.notifier).markAllRead();
      case UserRole.driver:
        ref.read(driverNotificationsProvider.notifier).markAllRead();
    }
  }

  bool _showFab(WidgetRef ref, AppMainTab tab) => switch (role) {
        UserRole.customer => _customerShowFab(ref, tab),
        UserRole.driver => _driverShowFab(ref, tab),
      };

  bool _customerShowFab(WidgetRef ref, AppMainTab tab) {
    final shipmentsState = ref.watch(customerShipmentsProvider);
    if (shipmentsState.isLoading) return false;
    final hasActive = shipmentsState.active.isNotEmpty;
    final hasAny = shipmentsState.shipments.isNotEmpty;
    return (tab == AppMainTab.home && hasActive) ||
        (tab == AppMainTab.listings && hasAny);
  }

  bool _driverShowFab(WidgetRef ref, AppMainTab tab) {
    if (tab == AppMainTab.listings) return true;
    if (tab != AppMainTab.home) return false;
    final requestsState = ref.watch(driverShipmentRequestsProvider);
    return !requestsState.isLoading && requestsState.all.isNotEmpty;
  }
}
