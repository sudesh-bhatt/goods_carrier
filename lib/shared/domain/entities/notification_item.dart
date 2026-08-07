enum NotificationType {
  driverInterestReceived,
  shipmentRequest,
  shipmentRequestAccepted,
  shipmentAssigned,
  shipmentPickedUp,
  shipmentDelivered,
  tripRequestAccepted,
  tripRequestRejected,
  tripCancelled,
  subscriptionPurchase,
  subscriptionExpiryReminder,
  shipmentDropSuccess,
  paymentSuccess,
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.timeAgo,
    this.referenceId,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  /// Server-localized relative time (e.g. IST) from API `time_ago`.
  final String? timeAgo;
  final String? referenceId;    // TRK- / VB- / INV- id
  final bool isRead;

  NotificationItem markRead() => NotificationItem(
    id: id, type: type, title: title, body: body,
    createdAt: createdAt, timeAgo: timeAgo,
    referenceId: referenceId, isRead: true,
  );
}
