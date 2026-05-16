import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/notification_item.dart';

/// Notification card — [Figma Notifications](https://www.figma.com/design/wT5NdNeg7YVPPcq1nY9D2P/Goods-Carrier--Copy-?node-id=2013-3460).
class CustomerNotificationCard extends StatelessWidget {
  const CustomerNotificationCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final NotificationItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !item.isRead;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: colors.cardBackground,
        elevation: isUnread ? 2 : 0,
        shadowColor: colors.shadowCard,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(21.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: isUnread
                  ? Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _iconFor(item.type),
                    size: 22.w,
                    color: colors.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontFamily: FontRes.MANROPE_BOLD,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                context.l10n.notificationNewBadge,
                                style: TextStyle(
                                  fontFamily: FontRes.MANROPE_BOLD,
                                  fontSize: 10.sp,
                                  color: colors.primaryDark,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item.body,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 13.sp,
                          height: 1.45,
                          color: colors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _relativeTime(item.createdAt),
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 12.sp,
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread) ...[
                  SizedBox(width: 8.w),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    margin: EdgeInsets.only(top: 4.h),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType type) => switch (type) {
        NotificationType.shipmentPickedUp ||
        NotificationType.shipmentDelivered ||
        NotificationType.shipmentDropSuccess =>
          Icons.local_shipping_outlined,
        NotificationType.shipmentAssigned ||
        NotificationType.tripRequestAccepted =>
          Icons.assignment_turned_in_outlined,
        NotificationType.driverInterestReceived =>
          Icons.person_add_alt_1_outlined,
        NotificationType.tripCancelled => Icons.cancel_outlined,
        NotificationType.subscriptionPurchase ||
        NotificationType.paymentSuccess =>
          Icons.payments_outlined,
      };

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays}d ago';
  }
}
