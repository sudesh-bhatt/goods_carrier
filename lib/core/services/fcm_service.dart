import 'dart:async';
import 'dart:io';

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

/// Must be a top-level function for background isolate registration.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint('[FCM] background message: ${message.messageId}');
  }
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

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
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
    _debugLog('foreground message: ${message.messageId}');
    final notification = message.notification;
    if (notification == null) return;

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
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    _debugLog('opened from notification: ${message.data}');
    onNotificationOpened?.call(message);
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[FcmService] $message');
    }
  }
}
