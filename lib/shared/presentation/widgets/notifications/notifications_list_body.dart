import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../features/customer/presentation/providers/customer_notifications_provider.dart';
import '../../../domain/entities/notification_item.dart';
import '../../notifications/notifications_scope.dart';
import '../feedback/empty_state.dart';
import '../feedback/error_view.dart';
import 'app_notification_card.dart';
import 'app_notification_tokens.dart';

/// Scrollable notification list — shared by customer & driver.
class NotificationsListBody extends StatelessWidget {
  const NotificationsListBody({
    super.key,
    required this.notifications,
    required this.onMarkRead,
    this.scope = NotificationsScope.driver,
    this.onDelete,
    this.onTap,
    this.scrollController,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  final List<NotificationItem> notifications;
  final ValueChanged<String> onMarkRead;
  final NotificationsScope scope;
  final ValueChanged<String>? onDelete;
  final ValueChanged<NotificationItem>? onTap;
  final ScrollController? scrollController;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (notifications.isEmpty) {
      return ColoredBox(
        color: AppNotificationTokens.background,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: EmptyState(
                headline: l10n.emptyNotifications,
                subtitle: l10n.notificationNoNew,
                fallbackIcon: Icons.notifications_none_rounded,
              ),
            ),
          ),
        ),
      );
    }

    final itemCount = notifications.length + (hasMore || isLoadingMore ? 1 : 0);

    return ColoredBox(
      color: AppNotificationTokens.background,
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
        itemCount: itemCount,
        separatorBuilder: (context, index) {
          if (index >= notifications.length - 1) {
            return const SizedBox.shrink();
          }
          return SizedBox(height: 16.h);
        },
        itemBuilder: (context, index) {
          if (index >= notifications.length) {
            if (isLoadingMore) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (hasMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) => onLoadMore?.call());
            }
            return const SizedBox.shrink();
          }

          final item = notifications[index];
          final card = AppNotificationCard(
            item: item,
            scope: scope,
            onTap: () {
              if (!item.isRead) onMarkRead(item.id);
              onTap?.call(item);
            },
          );

          if (onDelete == null) return card;

          return Dismissible(
            key: ValueKey<String>('notification_${item.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 24.w),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: context.colors.error,
              ),
            ),
            onDismissed: (_) => onDelete!(item.id),
            child: card,
          );
        },
      ),
    );
  }
}

/// Loading, error, and list states for the notifications tab/screen.
class NotificationsContent extends StatelessWidget {
  const NotificationsContent({
    super.key,
    required this.state,
    required this.scope,
    required this.onRefresh,
    required this.onRetry,
    required this.onMarkRead,
    required this.onDelete,
    required this.onTap,
    required this.onLoadMore,
    this.scrollController,
  });

  final NotificationsState state;
  final NotificationsScope scope;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<String> onMarkRead;
  final ValueChanged<String> onDelete;
  final ValueChanged<NotificationItem> onTap;
  final VoidCallback onLoadMore;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (state.isLoading && state.items.isEmpty) {
      return const ColoredBox(
        color: AppNotificationTokens.background,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return ColoredBox(
        color: AppNotificationTokens.background,
        child: ErrorView(
          message: state.error!,
          onRetry: onRetry,
        ),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: onRefresh,
      child: NotificationsListBody(
        notifications: state.items,
        scope: scope,
        onMarkRead: onMarkRead,
        onDelete: onDelete,
        onTap: onTap,
        scrollController: scrollController,
        hasMore: state.hasMore,
        isLoadingMore: state.isLoadingMore,
        onLoadMore: onLoadMore,
      ),
    );
  }
}
