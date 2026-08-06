import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';

/// Android notification channel used for FCM foreground display.
const _androidChannel = AndroidNotificationChannel(
  'goods_carrier_high_importance',
  'Goods Carrier Notifications',
  description: 'Push notifications for shipments, trips, and account alerts.',
  importance: Importance.high,
);

/// Full FCM payload dump for debugging tray / receive issues (debug only).
void _logRemoteMessage(String source, RemoteMessage message) {
  if (!kDebugMode) return;

  final notification = message.notification;
  final payload = <String, Object?>{
    'source': source,
    'messageId': message.messageId,
    'from': message.from,
    'sentTime': message.sentTime?.toIso8601String(),
    'collapseKey': message.collapseKey,
    'category': message.category,
    'contentAvailable': message.contentAvailable,
    'mutableContent': message.mutableContent,
    'messageType': message.messageType,
    'ttl': message.ttl,
    'threadId': message.threadId,
    'data': message.data,
    'notification': notification == null
        ? null
        : {
            'title': notification.title,
            'body': notification.body,
            'titleLocKey': notification.titleLocKey,
            'bodyLocKey': notification.bodyLocKey,
            'titleLocArgs': notification.titleLocArgs,
            'bodyLocArgs': notification.bodyLocArgs,
            'android': notification.android == null
                ? null
                : {
                    'channelId': notification.android!.channelId,
                    'clickAction': notification.android!.clickAction,
                    'count': notification.android!.count,
                    'imageUrl': notification.android!.imageUrl,
                    'link': notification.android!.link?.toString(),
                    'priority': notification.android!.priority.name,
                    'smallIcon': notification.android!.smallIcon,
                    'sound': notification.android!.sound,
                    'ticker': notification.android!.ticker,
                    'tag': notification.android!.tag,
                    'visibility': notification.android!.visibility.name,
                  },
            'apple': notification.apple == null
                ? null
                : {
                    'badge': notification.apple!.badge,
                    'sound': notification.apple!.sound?.name,
                    'imageUrl': notification.apple!.imageUrl,
                    'subtitle': notification.apple!.subtitle,
                  },
          },
  };

  debugPrint('[FCM] ===== $source FULL PAYLOAD =====');
  debugPrint(const JsonEncoder.withIndent('  ').convert(payload));
  if (notification == null) {
    debugPrint(
      '[FCM] WARNING: notification block is null — data-only message. '
      'Foreground tray will NOT show unless we build a local notification '
      'from data. Background/terminated tray also needs a notification block '
      '(or native display handling).',
    );
  }
}

/// Must be a top-level function for background isolate registration.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _logRemoteMessage('background/onReceive', message);
}

/// Handles FCM permission, token lifecycle, and foreground display.
///
/// The current token is attached to API requests as `X-FCM-Token` via
/// [HeadersInterceptor] (with `X-Device-Id` / `X-Device-Type`).
class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  String? _token;
  String? get currentToken => _token;

  var _initialized = false;
  Future<void>? _initializeFuture;

  /// Callback when a notification opens the app (cold or warm).
  void Function(RemoteMessage message)? onNotificationOpened;

  /// Idempotent: safe to await from splash before any API calls.
  Future<void> initialize({bool requestPermission = true}) {
    if (_initialized) return Future.value();
    return _initializeFuture ??= _doInitialize(requestPermission: requestPermission);
  }

  Future<void> _doInitialize({required bool requestPermission}) async {
    try {
      if (requestPermission) {
        await this.requestPermission();
      }

      if (Platform.isIOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        await _waitForApnsToken();
      }

      // Fetch token before local-notification setup so splash APIs get
      // X-FCM-Token as soon as possible.
      _token = await _messaging.getToken();
      if (_token == null || _token!.isEmpty) {
        // iOS simulator / delayed APNs — short retry.
        await Future<void>.delayed(const Duration(milliseconds: 800));
        _token = await _messaging.getToken();
      }
      _debugLog('FCM token: $_token');

      await _setupLocalNotifications();

      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
        _token = token;
        _debugLog('FCM token refreshed: $token');
      });

      await _foregroundSub?.cancel();
      _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      await _openedAppSub?.cancel();
      _openedAppSub =
          FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        _onMessageOpened(initial);
      }

      _initialized = true;
    } catch (e, st) {
      _initializeFuture = null;
      _debugLog('initialize failed: $e\n$st');
      rethrow;
    }
  }

  /// iOS returns null from [FirebaseMessaging.getToken] until APNs is ready.
  Future<void> _waitForApnsToken() async {
    for (var i = 0; i < 10; i++) {
      final apns = await _messaging.getAPNSToken();
      if (apns != null && apns.isNotEmpty) {
        _debugLog('APNs token ready');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    _debugLog('APNs token not available yet (simulator / no Push entitlement?)');
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _token = null;
    _initialized = false;
    _initializeFuture = null;
  }

  /// Removes this app's notifications from the system tray (Android shade / iOS).
  ///
  /// Call on logout and session expiry so prior-user pushes do not linger.
  Future<void> clearTrayNotifications() async {
    try {
      await _localNotifications.cancelAll();
      _debugLog('cleared all tray notifications');
    } catch (e) {
      _debugLog('clearTrayNotifications failed: $e');
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
  }

  Future<void> _setupLocalNotifications() async {
    // Stock Android requires a white alpha silhouette — not the launcher icon.
    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        _debugLog('local notification tapped: ${response.payload}');
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    _logRemoteMessage('foreground/onMessage', message);
    final notification = message.notification;
    if (notification == null) {
      _debugLog(
        'skipping local tray display — message.notification is null '
        '(data-only payload)',
      );
      return;
    }

    _debugLog(
      'showing local notification title="${notification.title}" '
      'body="${notification.body}" channel=${_androidChannel.id}',
    );
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          // Small icon: white silhouette (required on AOSP / Motorola).
          icon: '@drawable/ic_notification',
          // Large icon: full-color brand mark in expanded shade (Samsung-like).
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: const Color(0xFFFF6D00),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    _logRemoteMessage('opened/onMessageOpenedApp', message);
    onNotificationOpened?.call(message);
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[FcmService] $message');
    }
  }
}
