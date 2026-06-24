import '../../../core/dummy/dummy_notifications.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/models/notifications_page_result.dart';
import '../../domain/repositories/i_notifications_repository.dart';

class LocalNotificationsRepository implements INotificationsRepository {
  LocalNotificationsRepository({this.forDriver = false});

  final bool forDriver;
  final List<NotificationItem> _items = [];

  List<NotificationItem> get _seed =>
      forDriver ? DummyNotifications.driver : DummyNotifications.customer;

  List<NotificationItem> get _source =>
      _items.isEmpty ? List<NotificationItem>.from(_seed) : _items;

  @override
  Future<NotificationsPageResult> listNotifications({
    bool unreadOnly = false,
    int page = 1,
    int perPage = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final filtered = unreadOnly
        ? _source.where((n) => !n.isRead).toList(growable: false)
        : List<NotificationItem>.from(_source);
    final start = (page - 1) * perPage;
    if (start >= filtered.length) {
      final lastPage = filtered.isEmpty
          ? 1
          : (filtered.length / perPage).ceil();
      return NotificationsPageResult(
        items: const [],
        currentPage: page,
        lastPage: lastPage,
        total: filtered.length,
      );
    }
    final end = (start + perPage).clamp(0, filtered.length);
    final lastPage = (filtered.length / perPage).ceil().clamp(1, 999999);
    return NotificationsPageResult(
      items: filtered.sublist(start, end),
      currentPage: page,
      lastPage: lastPage,
      total: filtered.length,
    );
  }

  @override
  Future<void> markRead(String id) async {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].id == id) {
        _items[i] = _items[i].markRead();
        return;
      }
    }
    final seeded = List<NotificationItem>.from(_seed);
    for (var i = 0; i < seeded.length; i++) {
      if (seeded[i].id == id) seeded[i] = seeded[i].markRead();
    }
    _items
      ..clear()
      ..addAll(seeded);
  }

  @override
  Future<void> markAllRead() async {
    final source = _items.isEmpty ? _seed : _items;
    _items
      ..clear()
      ..addAll(source.map((n) => n.markRead()));
  }

  @override
  Future<void> deleteNotification(String id) async {
    if (_items.isEmpty) {
      _items.addAll(_seed.where((n) => n.id != id));
      return;
    }
    _items.removeWhere((n) => n.id == id);
  }
}
