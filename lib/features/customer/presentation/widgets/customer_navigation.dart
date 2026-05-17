import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/navigation/customer_bottom_nav_bar.dart';

/// Switches tabs inside the customer [StatefulNavigationShell] (no full route).
void navigateCustomerTab(BuildContext context, CustomerMainTab tab) {
  final shell = StatefulNavigationShell.maybeOf(context);
  if (shell != null) {
    shell.goBranch(
      tab.index,
      initialLocation: tab.index == shell.currentIndex,
    );
    return;
  }

  final path = switch (tab) {
    CustomerMainTab.home => AppRoutes.customerHome,
    CustomerMainTab.shipments => AppRoutes.customerHistory,
    CustomerMainTab.notifications => AppRoutes.customerNotifications,
    CustomerMainTab.profile => AppRoutes.customerProfile,
  };
  if (GoRouterState.of(context).matchedLocation != path) {
    context.go(path);
  }
}
