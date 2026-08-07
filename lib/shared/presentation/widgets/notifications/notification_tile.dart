import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/entities/notification_item.dart';

/// List tile for a [NotificationItem] with read/unread state and type icon.
///
/// Unread tiles display a coloured background strip + blue dot indicator.
/// Tapping any tile fires [onTap]; long-press fires [onMarkRead] if supplied.
///
/// ```dart
/// ListView.separated(
///   itemBuilder: (ctx, i) => NotificationTile(
///     item: notifications[i],
///     onTap: () => _handleNotifTap(notifications[i]),
///     onMarkRead: () => ref.read(notifProvider.notifier).markRead(notifications[i].id),
///   ),
///   ...
/// )
/// ```
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.item,
    this.onTap,
    this.onMarkRead,
  });

  final NotificationItem item;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !item.isRead;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onMarkRead,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isUnread ? colors.notificationUnread : Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.base.w,
          vertical: AppDimensions.md.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Type icon ───────────────────────────────────────────────
            _TypeIcon(type: item.type, isUnread: isUnread),

            SizedBox(width: AppDimensions.md.w),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row + unread dot
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        SizedBox(width: AppDimensions.xs.w),
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Body
                  Text(
                    item.body,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Timestamp
                  Text(
                    _displayTimestamp(item),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayTimestamp(NotificationItem item) {
    final fromApi = item.timeAgo?.trim();
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    return _relativeTimestamp(item.createdAt);
  }

  String _relativeTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return dt.shortDate;
  }
}

// ─── Type icon ────────────────────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type, required this.isUnread});
  final NotificationType type;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (iconData, bg) = _resolveStyle(type, colors);

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
      ),
      child: Icon(iconData, size: AppDimensions.iconMd.w, color: colors.primary),
    );
  }

  (IconData, Color) _resolveStyle(NotificationType type, dynamic colors) {
    return switch (type) {
      NotificationType.driverInterestReceived => (
        Icons.person_add_alt_1_outlined,
        colors.primary.withOpacity(0.1),
      ),
      NotificationType.shipmentRequest => (
        Icons.add_box_outlined,
        colors.primary.withOpacity(0.1),
      ),
      NotificationType.shipmentRequestAccepted ||
      NotificationType.shipmentAssigned => (
        Icons.assignment_turned_in_outlined,
        colors.success.withOpacity(0.1),
      ),
      NotificationType.shipmentPickedUp => (
        Icons.local_shipping_outlined,
        colors.primary.withOpacity(0.1),
      ),
      NotificationType.shipmentDelivered => (
        Icons.check_circle_outline_rounded,
        colors.success.withOpacity(0.1),
      ),
      NotificationType.tripRequestAccepted => (
        Icons.thumb_up_alt_outlined,
        colors.primary.withOpacity(0.1),
      ),
      NotificationType.tripRequestRejected ||
      NotificationType.tripCancelled => (
        Icons.cancel_outlined,
        colors.error.withOpacity(0.1),
      ),
      NotificationType.subscriptionPurchase ||
      NotificationType.subscriptionExpiryReminder => (
        Icons.payments_outlined,
        colors.success.withOpacity(0.1),
      ),
      NotificationType.shipmentDropSuccess => (
        Icons.location_on_outlined,
        colors.success.withOpacity(0.1),
      ),
      NotificationType.paymentSuccess => (
        Icons.payments_outlined,
        colors.success.withOpacity(0.1),
      ),
    };
  }
}

// ─── DateTime shortDate extension used locally ────────────────────────────────

extension on DateTime {
  String get shortDate {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '$day ${months[month - 1]} $year';
  }
}
