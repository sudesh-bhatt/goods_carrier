import '../../../domain/entities/notification_item.dart';

abstract final class NotificationsApiMapper {
  static NotificationItem fromJson(Map<String, dynamic> json) => NotificationItem(
        id: _stringId(json['id']),
        type: _parseType(json['type'] as String?),
        title: _firstString(json, ['title', 'subject']),
        body: _firstString(json, ['body', 'message', 'description']),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        timeAgo: _nullableString(json['time_ago']),
        referenceId: _extractReferenceId(json),
        isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      );

  static NotificationType _parseType(String? raw) {
    final normalized = raw?.trim().toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'driver_interest' ||
      'driver_interest_received' ||
      'interest_received' =>
        NotificationType.driverInterestReceived,
      'shipment_request' ||
      'trip_request' ||
      'trip_request_created' =>
        NotificationType.shipmentRequest,
      'shipment_request_accepted' =>
        NotificationType.shipmentRequestAccepted,
      'shipment_assigned' || 'assigned' => NotificationType.shipmentAssigned,
      'shipment_picked_up' || 'picked_up' => NotificationType.shipmentPickedUp,
      'shipment_delivered' || 'delivered' => NotificationType.shipmentDelivered,
      'trip_request_accepted' || 'request_accepted' =>
        NotificationType.tripRequestAccepted,
      'trip_request_rejected' || 'request_rejected' =>
        NotificationType.tripRequestRejected,
      'trip_cancelled' || 'cancelled' => NotificationType.tripCancelled,
      'subscription_purchase' || 'subscription' =>
        NotificationType.subscriptionPurchase,
      'subscription_expiry_reminder' ||
      'subscription_expiring' ||
      'subscription_expiry' =>
        NotificationType.subscriptionExpiryReminder,
      'shipment_drop_success' || 'drop_success' =>
        NotificationType.shipmentDropSuccess,
      'payment_success' || 'payment' => NotificationType.paymentSuccess,
      _ => NotificationType.shipmentAssigned,
    };
  }

  static String _stringId(dynamic raw) {
    if (raw == null) return '';
    return raw.toString();
  }

  static String? _extractReferenceId(Map<String, dynamic> json) {
    final direct = _nullableString(json['reference_id'] ?? json['reference']);
    if (direct != null) return direct;

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      for (final key in [
        'shipment_id',
        'trip_id',
        'reference_id',
        'id',
      ]) {
        final value = _nullableString(data[key]);
        if (value != null) return value;
      }
    }
    return null;
  }

  static String? _nullableString(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static String _firstString(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return '';
  }
}
