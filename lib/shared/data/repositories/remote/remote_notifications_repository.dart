import '../../../domain/models/notifications_page_result.dart';
import '../../../domain/repositories/i_notifications_repository.dart';
import '../../api/notifications/notifications_api_client.dart';

class RemoteNotificationsRepository implements INotificationsRepository {
  RemoteNotificationsRepository({required NotificationsApiClient apiClient})
      : _api = apiClient;

  final NotificationsApiClient _api;

  @override
  Future<NotificationsPageResult> listNotifications({
    bool unreadOnly = false,
    int page = 1,
    int perPage = 20,
  }) =>
      _api.listNotifications(
        unreadOnly: unreadOnly,
        page: page,
        perPage: perPage,
      );

  @override
  Future<void> markRead(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) throw ArgumentError('Invalid notification id: $id');
    await _api.markRead(parsed);
  }

  @override
  Future<void> markAllRead() => _api.markAllRead();

  @override
  Future<void> deleteNotification(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) throw ArgumentError('Invalid notification id: $id');
    await _api.deleteNotification(parsed);
  }
}
