import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../features/customer/presentation/providers/customer_notifications_provider.dart';
import '../../domain/entities/notification_item.dart';
import '../widgets/notifications/notifications_list_body.dart';
import 'notifications_scope.dart';

/// Shared notifications tab — same UI; data source depends on [scope].
class NotificationsTab extends ConsumerStatefulWidget {
  const NotificationsTab({super.key, required this.scope});

  final NotificationsScope scope;

  @override
  ConsumerState<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<NotificationsTab>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

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
          NotificationType.tripRequestRejected ||
          NotificationType.tripCancelled =>
            AppRoutes.driverTripDetailOf(refId),
          NotificationType.subscriptionPurchase ||
          NotificationType.subscriptionExpiryReminder ||
          NotificationType.paymentSuccess =>
            AppRoutes.driverSubscriptionPlans,
          _ => AppRoutes.driverShipmentDetailOf(refId),
        };
        context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = _watchState();

    return NotificationsContent(
      state: state,
      scope: widget.scope,
      scrollController: _scrollController,
      onRefresh: () => _notifier().refresh(),
      onRetry: () => _notifier().refresh(),
      onMarkRead: (id) => _notifier().markRead(id),
      onDelete: (id) => _notifier().deleteNotification(id),
      onTap: _onNotificationTap,
      onLoadMore: () => _notifier().loadMore(),
    );
  }
}
