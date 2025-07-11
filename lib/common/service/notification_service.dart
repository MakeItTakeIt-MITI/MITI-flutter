import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/notification/model/push_model.dart';

import '../../notification/view/notification_screen.dart';
import '../../notification_provider.dart';
import '../model/entity_enum.dart';
import '../provider/router_provider.dart';
import 'fcm_service.dart';

class NotificationService {
  final WidgetRef _ref;
  late final FCMService _fcmService;

  NotificationService(this._ref) {
    _fcmService = FCMService(_ref);
  }

  void initialize() {
    _setupLocalNotifications();
  }

  void dispose() {
    // Local notifications는 별도 dispose가 필요하지 않음
  }

  void _setupLocalNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final notification = await _initLocalNotification();
      _ref
          .read(notificationProvider.notifier)
          .setNotificationPlugin(notification);
    });
  }

  Future<FlutterLocalNotificationsPlugin> _initLocalNotification() async {
    final localNotification = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await localNotification.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse: _backgroundRouting,
      onDidReceiveNotificationResponse: _foregroundRouting,
    );

    return localNotification;
  }

  void _foregroundRouting(NotificationResponse details) async {
    log('_foregroundRouting = $details');
    log("details.payload = ${details.payload}");

    final model = _parseNotificationPayload(details.payload);
    if (model != null) {
      _fcmService.handleMessage(model);
    }
  }

  void _backgroundRouting(NotificationResponse details) {
    log('_backgroundRouting = $details');
    rootNavKey.currentContext?.goNamed(NotificationScreen.routeName);
  }

  PushDataModel? _parseNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      // & 기준으로 문자열을 분할
      final parts = payload.split('&');
      final resultMap = <String, String>{};

      for (final part in parts) {
        final keyValue = part.split('=');
        if (keyValue.length == 2) {
          resultMap[keyValue[0]] = keyValue[1];
        }
      }

      final topicEnum = PushNotificationTopicType.stringToEnum(
        value: resultMap['topic']!,
      );

      return PushDataModel(
        pushId: resultMap['pushId']!,
        topic: topicEnum,
        gameId: resultMap['gameId'],
      );
    } catch (e) {
      log('Error parsing notification payload: $e');
      return null;
    }
  }
}
