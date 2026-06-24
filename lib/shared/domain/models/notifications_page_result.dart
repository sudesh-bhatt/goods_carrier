import '../entities/notification_item.dart';

class NotificationsPageResult {
  const NotificationsPageResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    this.total = 0,
  });

  final List<NotificationItem> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasNextPage => currentPage < lastPage;
}
