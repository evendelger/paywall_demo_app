import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:paywall_demo/src/core/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // TODO(template): после `flutterfire configure` заменить на
  // `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
  await Firebase.initializeApp();
  await NotificationService.setupFlutterNotifications(message: message);

  mainTalker.info('Handling a background message ${message.messageId}');
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  mainTalker.info(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    mainTalker.info(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

class NotificationService {
  static Future<void> setup() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      await setupFlutterNotifications();
    }

    await _initialize();
  }

  static Future<void> _initialize() async {
    await NotificationService.flutterLocalNotificationsPlugin?.cancelAll();

    final notificationAppLaunchDetails = !kIsWeb && Platform.isLinux
        ? null
        : await flutterLocalNotificationsPlugin
              ?.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
    }
    await flutterLocalNotificationsPlugin?.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            final payload = notificationResponse.payload;
            if (payload != null) {
              final data = Map<String, Object?>.from(
                jsonDecode(payload) as Map,
              );
              selectNotificationStream.add(data);
            }
          },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static const initializationSettingsAndroid = AndroidInitializationSettings(
    'ic_stat_icon',
  );

  static const initializationSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  static const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  static final selectNotificationStream =
      StreamController<Map<String, Object?>?>.broadcast();

  static String? selectedNotificationPayload;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static late AndroidNotificationChannel channel;

  static var _isFlutterLocalNotificationsInitialized = false;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin?.cancelAll();
    // await FlutterAppBadger.removeBadge();
  }

  static Future<void> setupFlutterNotifications({
    RemoteMessage? message,
  }) async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'Важные уведомления',
      importance: Importance.high,
      enableLights: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    _isFlutterLocalNotificationsInitialized = true;
  }

  static Future<void> showFlutterNotification(RemoteMessage message) async {
    final data = message.data;
    mainTalker.info(jsonEncode(data));

    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      await flutterLocalNotificationsPlugin?.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        payload: jsonEncode(data),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            setAsGroupSummary: true,
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: Colors.black,
            icon: 'ic_stat_icon',
          ),
        ),
      );
    }
  }

  static void close() => selectNotificationStream.close();
}
