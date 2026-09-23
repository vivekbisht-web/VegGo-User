import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/local_storage/shared_prefs_helper.dart';
import 'package:vegon_user/core/network/api_client.dart';
import 'package:vegon_user/routes/app_routes.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔥 [FCM] Handling background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._internal();
  static final PushNotificationService instance = PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'veggo_high_importance_channel',
    'VegGo High Importance Notifications',
    description: 'This channel is used for important VegGo app notifications.',
    importance: Importance.high,
  );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Local notifications setup for foreground heads-up banner
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          _handleNotificationPayload(details.payload);
        },
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_androidChannel);
      }

      // Request FCM permissions
      await _requestPermissions();

      // Configure foreground presentation options for iOS
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Foreground message listener
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Background app opened message listener (User taps notification when app in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);

      // Terminated app initial message listener (User taps notification when app was killed)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _onNotificationOpenedApp(initialMessage);
      }

      // FCM Token refresh listener
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('🔥 [FCM] Token refreshed: $newToken');
        registerDeviceToken(tokenOverride: newToken);
      });
    } catch (e) {
      debugPrint('⚠️ [PushNotificationService] Initialization error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('🔥 [FCM] User permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('⚠️ [FCM] Permission request error: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('🔥 [FCM] Foreground message received: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'] ?? message.data['screen'],
      );
    }
  }

  void _onNotificationOpenedApp(RemoteMessage message) {
    debugPrint('🔥 [FCM] Notification opened app: ${message.data}');
    final route = message.data['route'] ?? message.data['screen'];
    _handleNotificationPayload(route);
  }

  void _handleNotificationPayload(String? route) {
    if (route != null && route.isNotEmpty) {
      try {
        Get.toNamed(route);
      } catch (_) {
        Get.toNamed(AppRoutes.notifications);
      }
    } else {
      Get.toNamed(AppRoutes.notifications);
    }
  }

  /// Registers the device token with the backend API
  /// POST /notifications/device-token with { "token": "...", "platform": "ANDROID" | "IOS" }
  Future<bool> registerDeviceToken({String? tokenOverride}) async {
    try {
      if (!SharedPrefsHelper.hasTokens()) {
        debugPrint('🔥 [FCM] Skipping device token registration: User not authenticated');
        return false;
      }

      final String? token = tokenOverride ?? await _fcm.getToken();
      if (token == null || token.trim().isEmpty) {
        debugPrint('⚠️ [FCM] Failed to fetch device FCM token');
        return false;
      }

      final String platformName = Platform.isAndroid
          ? 'ANDROID'
          : Platform.isIOS
              ? 'IOS'
              : 'ANDROID';

      debugPrint('🔥 [FCM] Registering device token to backend: $token ($platformName)');

      final response = await _apiClient.post(
        ApiEndpoints.deviceToken,
        data: {
          'token': token,
          'platform': platformName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await SharedPrefsHelper.saveFcmToken(token);
        debugPrint('✅ [FCM] Device token registered successfully on server');
        return true;
      } else {
        debugPrint('⚠️ [FCM] Device token registration API failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Error registering device token: $e');
      return false;
    }
  }

  /// Deletes the device token from backend API upon logout
  /// DELETE /notifications/device-token?token=...
  Future<bool> unregisterDeviceToken() async {
    try {
      String? token = SharedPrefsHelper.getFcmToken();
      if (token == null || token.trim().isEmpty) {
        try {
          token = await _fcm.getToken();
        } catch (_) {}
      }

      if (token == null || token.trim().isEmpty) {
        debugPrint('🔥 [FCM] No token available to unregister');
        await SharedPrefsHelper.clearFcmToken();
        return true;
      }

      debugPrint('🔥 [FCM] Deleting device token from backend: $token');

      final response = await _apiClient.delete(
        ApiEndpoints.deviceToken,
        queryParameters: {'token': token},
      );

      await SharedPrefsHelper.clearFcmToken();

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ [FCM] Device token unregistered successfully from server');
        return true;
      } else {
        debugPrint('⚠️ [FCM] Device token unregister API status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Error unregistering device token: $e');
      await SharedPrefsHelper.clearFcmToken();
      return false;
    }
  }
}
