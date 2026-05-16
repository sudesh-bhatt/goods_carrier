import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/navigation/customer_bottom_nav_bar.dart';

/// Switches between customer main tabs via [GoRouter] (no deep stack).
void navigateCustomerTab(BuildContext context, CustomerMainTab tab) {
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
