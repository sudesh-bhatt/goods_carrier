import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/dummy/dummy_notifications.dart';
import '../../../../shared/domain/entities/notification_item.dart';

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CustomerNotificationsNotifier
    extends StateNotifier<List<NotificationItem>> {
  CustomerNotificationsNotifier() : super(DummyNotifications.customer);

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markRead(String id) {
    state = state.map((n) => n.id == id ? n.markRead() : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.markRead()).toList();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final customerNotificationsProvider = StateNotifierProvider<
    CustomerNotificationsNotifier, List<NotificationItem>>(
  (ref) => CustomerNotificationsNotifier(),
);

/// Derived provider: unread count badge for AppBar action.
final customerUnreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(customerNotificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});
