import '../../shared/domain/entities/notification_item.dart';

class DummyNotifications {
  DummyNotifications._();

  static final List<NotificationItem> customer = [
    NotificationItem(
      id: 'N-001', type: NotificationType.driverInterestReceived,
      title: 'Driver Interested',
      body: 'Vikram Singh has shown interest in your shipment #TRK-8829',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      referenceId: 'TRK-8829',
    ),
    NotificationItem(
      id: 'N-002', type: NotificationType.shipmentAssigned,
      title: 'Driver Assigned',
      body: 'Your shipment #TRK-6645 has been assigned to a driver',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      referenceId: 'TRK-6645', isRead: true,
    ),
    NotificationItem(
      id: 'N-003', type: NotificationType.shipmentDelivered,
      title: 'Shipment Delivered',
      body: 'Your shipment #TRK-5512 has been delivered successfully',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      referenceId: 'TRK-5512', isRead: true,
    ),
  ];

  static final List<NotificationItem> driver = [
    NotificationItem(
      id: 'N-101',
      type: NotificationType.tripRequestAccepted,
      title: 'Trip Request Accepted',
      body:
          'Your Request #VB-9928 has been accepteed by the Customer',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      referenceId: 'VB-9928',
    ),
    NotificationItem(
      id: 'N-102',
      type: NotificationType.tripCancelled,
      title: 'Trip Cancel Successfully',
      body:
          'Your trip #VB-9928 has been picked up by the driver and is en route to Ahmedabad',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      referenceId: 'VB-9928',
      isRead: true,
    ),
    NotificationItem(
      id: 'N-103',
      type: NotificationType.subscriptionPurchase,
      title: 'Subscription Purchase',
      body:
          'Payment for invoice #INV-7721 was successful. Funds will arrive in 2-3 days.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      referenceId: 'INV-7721',
      isRead: true,
    ),
    NotificationItem(
      id: 'N-104',
      type: NotificationType.shipmentDropSuccess,
      title: 'Shipment Drop Successfully',
      body:
          'Your shipment #VB-9928 has been picked up by the driver and is en route to Ahmedabad',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      referenceId: 'VB-9928',
      isRead: true,
    ),
    NotificationItem(
      id: 'N-105',
      type: NotificationType.paymentSuccess,
      title: 'Payment Success',
      body:
          'Payment for invoice #INV-7721 was successful. Funds will arrive in 2-3 days.',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      referenceId: 'INV-7721',
      isRead: true,
    ),
  ];
}
