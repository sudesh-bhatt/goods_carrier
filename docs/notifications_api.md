# Notifications API — Flutter Implementation Guide

A complete, developer-ready reference for integrating the Goods Carrier Notifications API into a Flutter application.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Base URL & Headers](#2-base-url--headers)
3. [Data Models](#3-data-models)
4. [API Service Class](#4-api-service-class)
5. [Endpoint: List Notifications](#5-endpoint-list-notifications)
6. [Endpoint: Mark Notification Read](#6-endpoint-mark-notification-read)
7. [Endpoint: Mark All Notifications Read](#7-endpoint-mark-all-notifications-read)
8. [Endpoint: Delete Notification](#8-endpoint-delete-notification)
9. [Error Handling](#9-error-handling)
10. [State Management](#10-state-management)

---

## 1. Overview

The Notifications API provides endpoints to manage in-app notifications for authenticated users of the Goods Carrier platform. It supports:

- **Listing** paginated notifications with an optional unread-only filter
- **Marking** a single notification as read
- **Marking all** notifications as read in one call
- **Deleting** a specific notification

All endpoints require a valid Bearer token and a set of common device/locale headers. Responses follow a consistent JSON envelope, making it straightforward to build a unified notification centre in Flutter.

---

## 2. Base URL & Headers

### Base URL

```
{{base_url}}/api/notifications
```

The `base_url` value is injected at runtime (e.g. from your environment config or `flutter_dotenv`).

### Common Request Headers

Every request to the Notifications API must include the following headers:

| Header            | Value                    | Description                                      |
|-------------------|--------------------------|--------------------------------------------------|
| `Authorization`   | `Bearer {{token}}`       | JWT access token for the authenticated user      |
| `Accept`          | `application/json`       | Tells the server to return JSON                  |
| `Content-Type`    | `application/json`       | Request body format (even for bodyless requests) |
| `Accept-Language` | `{{language}}`           | Locale code, e.g. `en`, `hi`                     |
| `X-Device-Id`     | `{{device_id}}`          | Unique identifier for the device                 |
| `X-Device-Type`   | `{{device_type}}`        | Platform identifier, e.g. `android`, `ios`       |

### Centralised Header Builder

```dart
// lib/core/api/api_headers.dart

Map<String, String> buildHeaders({
  required String token,
  required String language,
  required String deviceId,
  required String deviceType,
}) {
  return {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Accept-Language': language,
    'X-Device-Id': deviceId,
    'X-Device-Type': deviceType,
  };
}
```

---

## 3. Data Models

### 3.1 `NotificationModel`

Represents a single notification object returned by the API.

```dart
// lib/features/notifications/models/notification_model.dart

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String? type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.type,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      type: json['type'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'is_read': isRead,
      'type': type,
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    bool? isRead,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### 3.2 `PaginationMeta`

Holds pagination metadata from list responses.

```dart
// lib/core/models/pagination_meta.dart

class PaginationMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
}
```

### 3.3 `NotificationListResponse`

Wraps the paginated list of notifications.

```dart
// lib/features/notifications/models/notification_list_response.dart

import 'notification_model.dart';
import '../../core/models/pagination_meta.dart';

class NotificationListResponse {
  final List<NotificationModel> notifications;
  final PaginationMeta meta;

  const NotificationListResponse({
    required this.notifications,
    required this.meta,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return NotificationListResponse(
      notifications: items,
      meta: PaginationMeta.fromJson(data),
    );
  }
}
```

### 3.4 `ApiResponse<T>` — Generic Wrapper

A lightweight wrapper used internally to propagate success/failure through the service layer.

```dart
// lib/core/models/api_response.dart

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  const ApiResponse({
    this.data,
    this.message,
    required this.success,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(data: data, success: true, message: message);
  }

  factory ApiResponse.failure(String message) {
    return ApiResponse(success: false, message: message);
  }
}
```

---

## 4. API Service Class

The `NotificationService` uses the [`dio`](https://pub.dev/packages/dio) package for HTTP communication. Add it to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0
```

```dart
// lib/features/notifications/services/notification_service.dart

import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../models/notification_list_response.dart';
import '../../core/models/api_response.dart';
import '../../core/api/api_headers.dart';
import '../../core/exceptions/api_exception.dart';

class NotificationService {
  final Dio _dio;
  final String baseUrl;

  NotificationService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// Builds the common headers for every request.
  Options _options({
    required String token,
    required String language,
    required String deviceId,
    required String deviceType,
  }) {
    return Options(
      headers: buildHeaders(
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
      ),
    );
  }

  // ── Endpoint methods are documented in sections 5–8 below ──
}
```

> **Tip:** In a real app, inject `NotificationService` via a dependency-injection solution (e.g. `get_it`, Riverpod `Provider`, or Flutter's `InheritedWidget`) so that the token and device metadata are resolved once and shared across the app.

---

## 5. Endpoint: List Notifications

### Details

| Property    | Value                          |
|-------------|--------------------------------|
| **Method**  | `GET`                          |
| **URL**     | `{{base_url}}/api/notifications` |

### Description

Returns a paginated list of notifications for the currently authenticated user. Use the `unread_only` flag to surface only unread items (e.g. for a badge count or a filtered view).

### Query Parameters

| Parameter    | Type   | Default | Description                              |
|--------------|--------|---------|------------------------------------------|
| `unread_only`| `bool` | `false` | When `true`, returns only unread items   |
| `page`       | `int`  | `1`     | Page number (1-based)                    |
| `per_page`   | `int`  | `10`    | Number of notifications per page         |

### Dart Method

```dart
// Inside NotificationService

/// Fetches a paginated list of notifications.
///
/// [unreadOnly] — when true, only unread notifications are returned.
/// [page]       — page number (1-based).
/// [perPage]    — items per page.
Future<ApiResponse<NotificationListResponse>> listNotifications({
  required String token,
  required String language,
  required String deviceId,
  required String deviceType,
  bool unreadOnly = false,
  int page = 1,
  int perPage = 10,
}) async {
  try {
    final response = await _dio.get(
      '$baseUrl/api/notifications',
      queryParameters: {
        'unread_only': unreadOnly,
        'page': page,
        'per_page': perPage,
      },
      options: _options(
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
      ),
    );

    final result = NotificationListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    return ApiResponse.success(result);
  } on DioException catch (e) {
    throw ApiException.fromDioException(e);
  }
}
```

### Usage Example

```dart
// In a widget, provider, or controller:

final service = NotificationService(baseUrl: AppConfig.baseUrl);

Future<void> loadNotifications() async {
  try {
    final response = await service.listNotifications(
      token: authProvider.token,
      language: localeProvider.languageCode,
      deviceId: deviceInfo.deviceId,
      deviceType: deviceInfo.deviceType,
      unreadOnly: false,
      page: 1,
      perPage: 20,
    );

    final notifications = response.data!.notifications;
    final meta = response.data!.meta;

    print('Loaded ${notifications.length} of ${meta.total} notifications');
    print('Has next page: ${meta.hasNextPage}');
  } on ApiException catch (e) {
    print('Error: ${e.message}');
  }
}
```

---

## 6. Endpoint: Mark Notification Read

### Details

| Property    | Value                                      |
|-------------|--------------------------------------------|
| **Method**  | `POST`                                     |
| **URL**     | `{{base_url}}/api/notifications/{id}/read` |

### Description

Marks a single notification (identified by its integer `id`) as read for the authenticated user. No request body is required.

### Path Parameters

| Parameter | Type  | Description              |
|-----------|-------|--------------------------|
| `id`      | `int` | The notification's ID    |

### Dart Method

```dart
// Inside NotificationService

/// Marks the notification with [notificationId] as read.
Future<ApiResponse<void>> markNotificationRead({
  required int notificationId,
  required String token,
  required String language,
  required String deviceId,
  required String deviceType,
}) async {
  try {
    await _dio.post(
      '$baseUrl/api/notifications/$notificationId/read',
      options: _options(
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
      ),
    );
    return ApiResponse.success(null, message: 'Notification marked as read.');
  } on DioException catch (e) {
    throw ApiException.fromDioException(e);
  }
}
```

### Usage Example

```dart
// Triggered when the user taps a notification tile:

Future<void> onNotificationTap(int notificationId) async {
  try {
    await service.markNotificationRead(
      notificationId: notificationId,
      token: authProvider.token,
      language: localeProvider.languageCode,
      deviceId: deviceInfo.deviceId,
      deviceType: deviceInfo.deviceType,
    );

    // Update local state to reflect the read status
    notificationProvider.markAsRead(notificationId);
  } on ApiException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  }
}
```

---

## 7. Endpoint: Mark All Notifications Read

### Details

| Property    | Value                                        |
|-------------|----------------------------------------------|
| **Method**  | `POST`                                       |
| **URL**     | `{{base_url}}/api/notifications/read-all`    |

### Description

Marks **all** unread notifications as read for the authenticated user in a single call. No path parameters or request body are required.

### Dart Method

```dart
// Inside NotificationService

/// Marks all unread notifications as read for the authenticated user.
Future<ApiResponse<void>> markAllNotificationsRead({
  required String token,
  required String language,
  required String deviceId,
  required String deviceType,
}) async {
  try {
    await _dio.post(
      '$baseUrl/api/notifications/read-all',
      options: _options(
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
      ),
    );
    return ApiResponse.success(null, message: 'All notifications marked as read.');
  } on DioException catch (e) {
    throw ApiException.fromDioException(e);
  }
}
```

### Usage Example

```dart
// Triggered by a "Mark all as read" button in the notification centre:

Future<void> onMarkAllRead() async {
  try {
    await service.markAllNotificationsRead(
      token: authProvider.token,
      language: localeProvider.languageCode,
      deviceId: deviceInfo.deviceId,
      deviceType: deviceInfo.deviceType,
    );

    // Refresh the list or update local state
    notificationProvider.markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  } on ApiException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  }
}
```

---

## 8. Endpoint: Delete Notification

### Details

| Property    | Value                                  |
|-------------|----------------------------------------|
| **Method**  | `DELETE`                               |
| **URL**     | `{{base_url}}/api/notifications/{id}`  |

### Description

Permanently deletes a single notification (identified by its integer `id`) for the authenticated user. No request body is required.

### Path Parameters

| Parameter | Type  | Description              |
|-----------|-------|--------------------------|
| `id`      | `int` | The notification's ID    |

### Dart Method

```dart
// Inside NotificationService

/// Deletes the notification with [notificationId].
Future<ApiResponse<void>> deleteNotification({
  required int notificationId,
  required String token,
  required String language,
  required String deviceId,
  required String deviceType,
}) async {
  try {
    await _dio.delete(
      '$baseUrl/api/notifications/$notificationId',
      options: _options(
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
      ),
    );
    return ApiResponse.success(null, message: 'Notification deleted.');
  } on DioException catch (e) {
    throw ApiException.fromDioException(e);
  }
}
```

### Usage Example

```dart
// Triggered by a swipe-to-dismiss or delete icon on a notification tile:

Future<void> onDeleteNotification(int notificationId) async {
  try {
    await service.deleteNotification(
      notificationId: notificationId,
      token: authProvider.token,
      language: localeProvider.languageCode,
      deviceId: deviceInfo.deviceId,
      deviceType: deviceInfo.deviceType,
    );

    // Remove from local list
    notificationProvider.remove(notificationId);
  } on ApiException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  }
}
```

---

## 9. Error Handling

### `ApiException`

Define a custom exception class that wraps Dio errors into a consistent shape:

```dart
// lib/core/exceptions/api_exception.dart

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Request timed out. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final serverMessage = _extractMessage(e.response?.data);
        return ApiException(
          message: serverMessage ?? _defaultMessageForStatus(statusCode),
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled.');

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection. Please check your network.',
        );

      default:
        return ApiException(
          message: e.message ?? 'An unexpected error occurred.',
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }

  static String _defaultMessageForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorised. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please slow down.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong (HTTP $statusCode).';
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
```

### Handling Pattern in the UI Layer

```dart
try {
  final response = await service.listNotifications(/* ... */);
  // handle success
} on ApiException catch (e) {
  if (e.statusCode == 401) {
    // Token expired — redirect to login
    authProvider.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  }
} catch (e) {
  // Catch-all for unexpected errors
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('An unexpected error occurred.')),
  );
}
```

---

## 10. State Management

The examples below show how to wire `NotificationService` into two popular state-management solutions.

### Option A — Provider (`ChangeNotifier`)

```dart
// lib/features/notifications/providers/notification_provider.dart

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../../core/exceptions/api_exception.dart';

enum NotificationStatus { idle, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;
  final String token;
  final String language;
  final String deviceId;
  final String deviceType;

  NotificationProvider({
    required NotificationService service,
    required this.token,
    required this.language,
    required this.deviceId,
    required this.deviceType,
  }) : _service = service;

  List<NotificationModel> _notifications = [];
  NotificationStatus _status = NotificationStatus.idle;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNextPage = true;

  List<NotificationModel> get notifications => _notifications;
  NotificationStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications = [];
      _hasNextPage = true;
    }

    if (!_hasNextPage) return;

    _status = NotificationStatus.loading;
    notifyListeners();

    try {
      final response = await _service.listNotifications(
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
        page: _currentPage,
      );

      _notifications.addAll(response.data!.notifications);
      _hasNextPage = response.data!.meta.hasNextPage;
      _currentPage++;
      _status = NotificationStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = NotificationStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markNotificationRead(
        notificationId: id,
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
      );
      _notifications = _notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      notifyListeners();
    } on ApiException {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllNotificationsRead(
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
      );
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } on ApiException {
      rethrow;
    }
  }

  Future<void> remove(int id) async {
    try {
      await _service.deleteNotification(
        notificationId: id,
        token: token,
        language: language,
        deviceId: deviceId,
        deviceType: deviceType,
      );
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } on ApiException {
      rethrow;
    }
  }
}
```

**Register in `main.dart`:**

```dart
ChangeNotifierProvider(
  create: (_) => NotificationProvider(
    service: NotificationService(baseUrl: AppConfig.baseUrl),
    token: authService.token,
    language: 'en',
    deviceId: deviceInfo.deviceId,
    deviceType: deviceInfo.deviceType,
  )..fetchNotifications(),
)
```

---

### Option B — Riverpod (`AsyncNotifier`)

```dart
// lib/features/notifications/providers/notification_riverpod.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

part 'notification_riverpod.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Future<List<NotificationModel>> build() async {
    final service = ref.read(notificationServiceProvider);
    final auth = ref.read(authProvider);
    final device = ref.read(deviceInfoProvider);

    final response = await service.listNotifications(
      token: auth.token,
      language: auth.language,
      deviceId: device.id,
      deviceType: device.type,
    );

    return response.data!.notifications;
  }

  Future<void> markAsRead(int id) async {
    final service = ref.read(notificationServiceProvider);
    final auth = ref.read(authProvider);
    final device = ref.read(deviceInfoProvider);

    await service.markNotificationRead(
      notificationId: id,
      token: auth.token,
      language: auth.language,
      deviceId: device.id,
      deviceType: device.type,
    );

    state = AsyncData(
      state.value!.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  Future<void> remove(int id) async {
    final service = ref.read(notificationServiceProvider);
    final auth = ref.read(authProvider);
    final device = ref.read(deviceInfoProvider);

    await service.deleteNotification(
      notificationId: id,
      token: auth.token,
      language: auth.language,
      deviceId: device.id,
      deviceType: device.type,
    );

    state = AsyncData(
      state.value!.where((n) => n.id != id).toList(),
    );
  }
}
```

**Consume in a widget:**

```dart
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationNotifierProvider);

    return notificationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (notifications) => ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.body),
            trailing: notification.isRead
                ? null
                : const Icon(Icons.circle, size: 10, color: Colors.blue),
            onTap: () => ref
                .read(notificationNotifierProvider.notifier)
                .markAsRead(notification.id),
          );
        },
      ),
    );
  }
}
```

---

*Generated for the Goods Carrier Flutter project. Keep this document in sync with any API contract changes.*
