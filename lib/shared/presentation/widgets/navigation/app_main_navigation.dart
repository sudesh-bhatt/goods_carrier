import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../domain/enums/user_role.dart';
import 'app_main_tab.dart';

/// Switches tabs inside a role [StatefulNavigationShell], or falls back to [context.go].
void navigateAppMainTab(
  BuildContext context,
  UserRole role,
  AppMainTab tab,
) {
  final shell = StatefulNavigationShell.maybeOf(context);
  if (shell != null) {
    shell.goBranch(
      tab.index,
      initialLocation: tab.index == shell.currentIndex,
    );
    return;
  }

  final path = _routeForTab(role, tab);
  if (GoRouterState.of(context).matchedLocation != path) {
    context.go(path);
  }
}

String _routeForTab(UserRole role, AppMainTab tab) => switch (role) {
      UserRole.customer => switch (tab) {
          AppMainTab.home => AppRoutes.customerHome,
          AppMainTab.listings => AppRoutes.customerHistory,
          AppMainTab.notifications => AppRoutes.customerNotifications,
          AppMainTab.profile => AppRoutes.customerProfile,
        },
      UserRole.driver => switch (tab) {
          AppMainTab.home => AppRoutes.driverHome,
          AppMainTab.listings => AppRoutes.driverMyTrips,
          AppMainTab.notifications => AppRoutes.driverNotifications,
          AppMainTab.profile => AppRoutes.driverProfile,
        },
    };

/// Customer-only helper (same shell tab order as driver).
void navigateCustomerTab(BuildContext context, AppMainTab tab) {
  navigateAppMainTab(context, UserRole.customer, tab);
}
