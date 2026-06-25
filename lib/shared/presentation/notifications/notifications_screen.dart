import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/theme_ext.dart';
import '../../../core/router/app_routes.dart';
import '../../../features/customer/presentation/providers/customer_notifications_provider.dart';
import '../../domain/entities/notification_item.dart';
import '../widgets/notifications/app_notifications_header.dart';
import '../widgets/notifications/app_notification_tokens.dart';
import '../widgets/notifications/notifications_list_body.dart';
import 'notifications_scope.dart';

/// Full-screen notifications — shared chrome for customer & driver routes.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key, required this.scope});

  final NotificationsScope scope;

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier().loadForTab();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _notifier().loadMore();
    }
  }

  NotificationsNotifier _notifier() {
    return switch (widget.scope) {
      NotificationsScope.customer =>
        ref.read(customerNotificationsProvider.notifier),
      NotificationsScope.driver =>
        ref.read(driverNotificationsProvider.notifier),
    };
  }

  NotificationsState _watchState() {
    return switch (widget.scope) {
      NotificationsScope.customer => ref.watch(customerNotificationsProvider),
      NotificationsScope.driver => ref.watch(driverNotificationsProvider),
    };
  }

  void _onNotificationTap(NotificationItem item) {
    final refId = item.referenceId;
    if (refId == null || refId.isEmpty) return;

    switch (widget.scope) {
      case NotificationsScope.customer:
        context.push(AppRoutes.shipmentDetailOf(refId));
      case NotificationsScope.driver:
        final route = switch (item.type) {
          NotificationType.tripRequestAccepted ||
          NotificationType.tripCancelled =>
            AppRoutes.driverTripDetailOf(refId),
          NotificationType.subscriptionPurchase =>
            AppRoutes.driverSubscriptionPlans,
          _ => AppRoutes.driverShipmentDetailOf(refId),
        };
        context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = _watchState();
    final hasUnread = state.unreadCount > 0;

    return Scaffold(
      backgroundColor: AppNotificationTokens.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppNotificationsHeader(
            title: l10n.notificationsTitle,
            showMarkAllRead: hasUnread,
            onMarkAllRead:
                hasUnread ? () => _notifier().markAllRead() : null,
          ),
          Expanded(
            child: NotificationsContent(
              state: state,
              scope: widget.scope,
              scrollController: _scrollController,
              onRefresh: () => _notifier().refresh(),
              onRetry: () => _notifier().refresh(),
              onMarkRead: (id) => _notifier().markRead(id),
              onDelete: (id) => _notifier().deleteNotification(id),
              onTap: _onNotificationTap,
              onLoadMore: () => _notifier().loadMore(),
            ),
          ),
        ],
      ),
    );
  }
}
