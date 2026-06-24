import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/models/notifications_page_result.dart';
import 'notifications_api_mapper.dart';

class NotificationsApiClient {
  NotificationsApiClient(this._dio);

  final Dio _dio;

  Future<NotificationsPageResult> listNotifications({
    bool unreadOnly = false,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {
        'unread_only': unreadOnly,
        'page': page,
        'per_page': perPage,
      },
    );
    final payload = ApiEnvelope.parsePaginatedData(response.data);
    return NotificationsPageResult(
      items: payload.items
          .map(NotificationsApiMapper.fromJson)
          .toList(growable: false),
      currentPage: payload.currentPage,
      lastPage: payload.lastPage,
      total: payload.total,
    );
  }

  Future<void> markRead(int id) async {
    await _dio.post<void>(ApiConstants.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _dio.post<void>(ApiConstants.notificationsReadAll);
  }

  Future<void> deleteNotification(int id) async {
    await _dio.delete<void>(ApiConstants.notificationDelete(id));
  }
}
