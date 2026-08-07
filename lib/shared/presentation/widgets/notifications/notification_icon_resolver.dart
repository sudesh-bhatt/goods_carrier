import 'package:flutter/material.dart';

import '../../../domain/entities/notification_item.dart';
import '../../../domain/enums/user_role.dart';
import 'app_notification_tokens.dart';

/// Icon + colors for a [NotificationItem] (role only affects customer-only types).
class NotificationIconStyle {
  const NotificationIconStyle({
    required this.icon,
    required this.foreground,
    required this.background,
    this.iconSize = 22,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final double iconSize;
}

abstract final class NotificationIconResolver {
  NotificationIconResolver._();

  static NotificationIconStyle resolve(
    NotificationType type, {
    UserRole role = UserRole.driver,
  }) {
    if (_isPaymentType(type)) {
      return const NotificationIconStyle(
        icon: Icons.payments_outlined,
        foreground: AppNotificationTokens.payment,
        background: AppNotificationTokens.iconGreenBg,
      );
    }

    return switch (type) {
      NotificationType.driverInterestReceived => NotificationIconStyle(
          icon: role == UserRole.customer
              ? Icons.person_add_alt_1_outlined
              : Icons.thumb_up_alt_outlined,
          foreground: AppNotificationTokens.primary,
          background: AppNotificationTokens.iconOrangeBg,
          iconSize: 20,
        ),
      // New shipment / trip request submitted
      NotificationType.shipmentRequest => const NotificationIconStyle(
          icon: Icons.add_box_outlined,
          foreground: AppNotificationTokens.primary,
          background: AppNotificationTokens.iconOrangeBg,
        ),
      // Customer accepted driver shipment request / assigned
      NotificationType.shipmentRequestAccepted ||
      NotificationType.shipmentAssigned =>
        const NotificationIconStyle(
          icon: Icons.assignment_turned_in_outlined,
          foreground: AppNotificationTokens.primary,
          background: AppNotificationTokens.iconOrangeBg,
        ),
      NotificationType.tripRequestAccepted => const NotificationIconStyle(
          icon: Icons.thumb_up_alt_outlined,
          foreground: AppNotificationTokens.primary,
          background: AppNotificationTokens.iconOrangeBg,
          iconSize: 20,
        ),
      NotificationType.tripRequestRejected ||
      NotificationType.tripCancelled =>
        const NotificationIconStyle(
          icon: Icons.close_rounded,
          foreground: AppNotificationTokens.primary,
          background: AppNotificationTokens.iconOrangeBg,
          iconSize: 20,
        ),
      NotificationType.shipmentDropSuccess ||
      NotificationType.shipmentPickedUp ||
      NotificationType.shipmentDelivered =>
        const NotificationIconStyle(
          icon: Icons.local_shipping_outlined,
          foreground: AppNotificationTokens.primary,
          background: AppNotificationTokens.iconOrangeBg,
        ),
      // Reached only if payment early-return above changes; keep exhaustive.
      NotificationType.subscriptionExpiryReminder ||
      NotificationType.subscriptionPurchase ||
      NotificationType.paymentSuccess =>
        const NotificationIconStyle(
          icon: Icons.payments_outlined,
          foreground: AppNotificationTokens.payment,
          background: AppNotificationTokens.iconGreenBg,
        ),
    };
  }

  static bool isPaymentType(NotificationType type) => _isPaymentType(type);

  static bool _isPaymentType(NotificationType type) =>
      type == NotificationType.subscriptionPurchase ||
      type == NotificationType.subscriptionExpiryReminder ||
      type == NotificationType.paymentSuccess;
}
