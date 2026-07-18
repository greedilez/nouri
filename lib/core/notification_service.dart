import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NotificationService {
  NotificationService(this.messaging, this.analytics);

  static const channel = AndroidNotificationChannel(
    'nouri_meal_updates',
    'Meal planning updates',
    description: 'Meal reminders and Nouri planning updates',
    importance: Importance.high,
  );

  final FirebaseMessaging messaging;
  final FirebaseAnalytics analytics;
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? foregroundSubscription;
  StreamSubscription<RemoteMessage>? openedSubscription;

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await localNotifications.initialize(settings: initializationSettings);
    final android = localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(channel);
    await android?.requestNotificationsPermission();
    final permission = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await analytics.logEvent(
      name: 'notification_permission',
      parameters: {'status': permission.authorizationStatus.name},
    );
    if (permission.authorizationStatus == AuthorizationStatus.authorized ||
        permission.authorizationStatus == AuthorizationStatus.provisional) {
      await messaging.subscribeToTopic('nouri_updates');
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await analytics.logEvent(name: 'fcm_token_ready');
      }
    }
    foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showRemoteMessage,
    );
    openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => analytics.logEvent(
        name: 'notification_opened',
        parameters: {'message_id': message.messageId ?? 'unknown'},
      ),
    );
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      await analytics.logEvent(
        name: 'notification_opened',
        parameters: {'message_id': initialMessage.messageId ?? 'unknown'},
      );
    }
  }

  Future<String?> token() => messaging.getToken();

  Future<void> showTestNotification() async {
    await localNotifications.show(
      id: 1001,
      title: 'Your Nouri plan is ready',
      body: 'Take a moment to review tomorrow’s meals.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nouri_meal_updates',
          'Meal planning updates',
          channelDescription: 'Meal reminders and Nouri planning updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'test_notification',
    );
    await analytics.logEvent(name: 'test_notification_shown');
  }

  Future<void> _showRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    await localNotifications.show(
      id: message.messageId.hashCode,
      title: notification?.title ?? message.data['title'] as String? ?? 'Nouri',
      body:
          notification?.body ??
          message.data['body'] as String? ??
          'Your meal plan has an update.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nouri_meal_updates',
          'Meal planning updates',
          channelDescription: 'Meal reminders and Nouri planning updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['route'] as String?,
    );
    await analytics.logEvent(
      name: 'notification_received_foreground',
      parameters: {'message_id': message.messageId ?? 'unknown'},
    );
  }

  Future<void> dispose() async {
    await foregroundSubscription?.cancel();
    await openedSubscription?.cancel();
  }
}
