import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:paywall_demo/src/core/utils/logger.dart';
import 'package:paywall_demo/src/feature/notification/service/notification_service.dart';

/// {@template notification_reciever}
/// Обработчик уведомлений
/// {@endtemplate}
class NotificationReciever extends StatefulWidget {
  /// {@macro notification_reciever}
  const NotificationReciever({required this.child, super.key});

  final Widget child;

  static Future<void> requestPermissions() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (Platform.isIOS) {
      await NotificationService.flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidImplementation = NotificationService
          .flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  @override
  State<NotificationReciever> createState() => _NotificationRecieverState();
}

class _NotificationRecieverState extends State<NotificationReciever>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    unawaited(_isAndroidPermissionGranted());
    unawaited(NotificationReciever.requestPermissions());
    _configureSelectNotificationSubject();
    unawaited(NotificationService.cancelAllNotifications());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(NotificationService.cancelAllNotifications());
    }
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      await NotificationService.flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
    }
  }

  void _configureSelectNotificationSubject() {
    NotificationService.selectNotificationStream.stream.listen((data) {});

    unawaited(
      FirebaseMessaging.instance.getInitialMessage().then(_selectNotification),
    );

    FirebaseMessaging.onMessage.listen(_showNotification);

    FirebaseMessaging.onMessageOpenedApp.listen(_selectNotification);
  }

  void _showNotification(RemoteMessage message) {
    mainTalker.info(jsonEncode(message.toMap()));
    unawaited(NotificationService.showFlutterNotification(message));
  }

  void _selectNotification(RemoteMessage? message) {
    final data = message?.data;

    if (data != null) {
      _showNotification(message!);

      NotificationService.selectNotificationStream.add(data);
    }
  }

  @override
  void dispose() {
    NotificationService.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
