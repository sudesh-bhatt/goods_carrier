enum NotificationType {
  driverInterestReceived,
  shipmentAssigned,
  shipmentPickedUp,
  shipmentDelivered,
  tripRequestAccepted,
  tripCancelled,
  subscriptionPurchase,
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
    this.referenceId,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? referenceId;    // TRK- / VB- / INV- id
  final bool isRead;

  NotificationItem markRead() => NotificationItem(
    id: id, type: type, title: title, body: body,
    createdAt: createdAt, referenceId: referenceId, isRead: true,
  );
}
