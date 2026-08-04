import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_ext.dart';
import '../../../domain/entities/notification_item.dart';
import '../../../domain/enums/user_role.dart';
import '../../notifications/notifications_scope.dart';
import 'app_notification_tokens.dart';
import 'notification_icon_resolver.dart';

/// Shared notification card — Figma layout for customer & driver.
class AppNotificationCard extends StatelessWidget {
  const AppNotificationCard({
    super.key,
    required this.item,
    this.onTap,
    this.scope = NotificationsScope.driver,
  });

  final NotificationItem item;
  final VoidCallback? onTap;
  final NotificationsScope scope;

  bool get _isPaymentType => NotificationIconResolver.isPaymentType(item.type);

  bool get _isPaymentRead => _isPaymentType && item.isRead;

  bool get _isShipmentUnread => !item.isRead;

  @override
  Widget build(BuildContext context) {
    final role = scope == NotificationsScope.customer
        ? UserRole.customer
        : UserRole.driver;
    final iconStyle = NotificationIconResolver.resolve(item.type, role: role);
    final timestamp = _displayTimestamp(item);
    final timestampInTitleRow = _isPaymentRead &&
        item.type == NotificationType.paymentSuccess &&
        timestamp.contains('Yesterday');

    Widget card = Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isPaymentRead
                ? AppNotificationTokens.cardPaymentRead
                : AppNotificationTokens.cardUnread,
            borderRadius: BorderRadius.circular(8),
            border: _isShipmentUnread
                ? Border.all(color: AppNotificationTokens.cardBorder)
                : null,
            boxShadow: _isShipmentUnread
                ? const [AppNotificationTokens.cardShadow]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIconBox(style: iconStyle),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppNotificationTokens.titleStyle,
                          ),
                        ),
                        if (_isShipmentUnread) ...[
                          const SizedBox(width: 8),
                          _NewBadge(label: context.l10n.notificationNewBadge),
                        ] else if (timestampInTitleRow) ...[
                          const SizedBox(width: 8),
                          Text(
                            timestamp,
                            textAlign: TextAlign.right,
                            style: AppNotificationTokens.timestampStyle,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: _isPaymentRead ? 2.75 : 2.8),
                    Text(
                      item.body,
                      style: AppNotificationTokens.bodyStyle,
                    ),
                    if (!_isPaymentRead) ...[
                      const SizedBox(height: 8.2),
                      Text(
                        timestamp,
                        style: AppNotificationTokens.timestampStyle,
                      ),
                    ],
                  ],
                ),
              ),
              if (_isShipmentUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: AppNotificationTokens.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (_isPaymentRead) {
      card = Opacity(opacity: 0.8, child: card);
    }

    return card;
  }

  /// Prefer API `time_ago` (server timezone, e.g. IST). Fallback for dummy data.
  static String _displayTimestamp(NotificationItem item) {
    final fromApi = item.timeAgo?.trim();
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    return _formatTimestamp(item.createdAt);
  }

  static String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays == 1) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return 'Yesterday, $hour:$minute $period';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      decoration: BoxDecoration(
        color: AppNotificationTokens.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(label, style: AppNotificationTokens.newBadgeStyle),
    );
  }
}

class _NotificationIconBox extends StatelessWidget {
  const _NotificationIconBox({required this.style});

  final NotificationIconStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(
        style.icon,
        size: style.iconSize,
        color: style.foreground,
      ),
    );
  }
}
