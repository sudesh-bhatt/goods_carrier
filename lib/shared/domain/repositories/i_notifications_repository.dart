import '../models/notifications_page_result.dart';

abstract class INotificationsRepository {
  Future<NotificationsPageResult> listNotifications({
    bool unreadOnly = false,
    int page = 1,
    int perPage = 20,
  });

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> deleteNotification(String id);
}
