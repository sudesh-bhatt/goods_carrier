import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/dummy/dummy_notifications.dart';
import '../../../../shared/domain/entities/notification_item.dart';

// ─── Notifier ─────────────────────────────────────────────────────────────────

class DriverNotificationsNotifier
    extends StateNotifier<List<NotificationItem>> {
  DriverNotificationsNotifier() : super(DummyNotifications.driver);

  void markRead(String id) {
    state = state.map((n) => n.id == id ? n.markRead() : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.markRead()).toList();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final driverNotificationsProvider = StateNotifierProvider<
    DriverNotificationsNotifier, List<NotificationItem>>(
  (ref) => DriverNotificationsNotifier(),
);

final driverUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(driverNotificationsProvider).where((n) => !n.isRead).length;
});
