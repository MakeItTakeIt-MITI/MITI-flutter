import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/notification/model/push_model.dart';
import 'package:miti/notification/view/notification_detail_screen.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/splash_screen.dart';

import '../../firebase_options.dart';
import '../../notification/provider/notification_provider.dart';
import '../model/entity_enum.dart';
import '../provider/router_provider.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log("background push data ${message.data}");
  log("Handling a background category: ${message.category}");
}

class FCMService {
  final WidgetRef _ref;

  FCMService(this._ref);

  void initialize() {
    _setupFCM();
    _getFcmToken();
  }

  void dispose() {
    // FCM은 별도 dispose가 필요하지 않음
  }

  Future<void> _getFcmToken() async {
    String? token;
    final messaging = FirebaseMessaging.instance;
    log('FCM Token 가져오기');

    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      print("apnToken : $apnsToken");

      if (apnsToken != null) {
        token = await messaging.getToken();
      } else {
        await Future<void>.delayed(const Duration(seconds: 3));
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          token = await messaging.getToken();
          _ref.read(fcmTokenProvider.notifier).update((state) => token);
        }
      }
    } else {
      token = await messaging.getToken();
    }

    _ref.read(fcmTokenProvider.notifier).update((state) => token);
    print("FCM Token: $token");
    log('FCM Token: $token');
  }

  void _setupFCM() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 백그라운드 메시지 처리
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 백그라운드에서 메시지 푸쉬를 열 때
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 앱이 처음 시작될 때 초기 메시지 처리
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);

    // 포그라운드에서 메시지 수신
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void _handleMessageOpenedApp(RemoteMessage event) async {
    log('onMessageOpenedApp');

    final gameId = event.data['game_id'];
    final pushId = event.data['push_notification_id'];
    final topic = event.data['topic'];
    final topicEnum = PushNotificationTopicType.stringToEnum(value: topic);
    final model = PushDataModel(pushId: pushId, topic: topicEnum, gameId: gameId);

    rootNavKey.currentContext?.goNamed(SplashScreen.routeName, extra: model);
  }

  void _handleInitialMessage(RemoteMessage? message) async {
    if (message != null && message.data.isNotEmpty) {
      await _ref.read(authProvider.notifier).autoLogin();

      final gameId = message.data['game_id'];
      final pushId = message.data['push_notification_id'];
      final topic = message.data['topic'];
      log('message.data = ${message.data}');

      final topicEnum = PushNotificationTopicType.stringToEnum(value: topic);
      final model = PushDataModel(pushId: pushId, topic: topicEnum, gameId: gameId);

      rootNavKey.currentContext?.goNamed(SplashScreen.routeName, extra: model);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null) {
      final gameId = message.data['game_id'];
      final pushId = message.data['push_notification_id'];
      final topic = message.data['topic'];

      final flutterLocalNotificationsPlugin =
          _ref.read(notificationProvider.notifier).getNotification;

      if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin?.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notification',
              importance: Importance.max,
              icon: 'ic_notification',
              ticker: 'ticker',
              color: Colors.black,
              ongoing: true,
              showWhen: true,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: "gameId=$gameId&pushId=$pushId&topic=$topic",
        );
      }

      await _updateBadgeCount();

      log('notification.title = ${notification.title}');
      log('notification.body = ${notification.body}');
    }
  }

  Future<void> _updateBadgeCount() async {
    final secureProvider = _ref.read(secureStorageProvider);
    final storagePushCnt = await secureProvider.read(key: 'pushCnt');

    final pushCnt = int.parse(storagePushCnt ?? '-1') + 1;
    AppBadgePlus.updateBadge(pushCnt);

    secureProvider.write(key: 'pushCnt', value: pushCnt.toString());
  }

  void handleMessage(PushDataModel model) {
    switch (model.topic) {
      case PushNotificationTopicType.general:
        _navigateToNotificationDetail(model.pushId, NoticeScreenType.notification);
        break;

      case PushNotificationTopicType.game_status_changed:
      case PushNotificationTopicType.new_participation:
      case PushNotificationTopicType.game_fee_changed:
        _ref
            .read(pushProvider(pushId: int.parse(model.pushId)).notifier)
            .get(pushId: int.parse(model.pushId));
        _navigateToGameDetail(model.gameId!);
        break;

      default:
        _navigateToNotificationDetail(model.pushId, NoticeScreenType.push);
    }
  }

  void _navigateToNotificationDetail(String pushId, NoticeScreenType type) {
    final pathParameters = {'id': pushId};
    rootNavKey.currentContext?.goNamed(
      NoticeDetailScreen.routeName,
      pathParameters: pathParameters,
      extra: type,
    );
  }

  void _navigateToGameDetail(String gameId) {
    final pathParameters = {'gameId': gameId};
    rootNavKey.currentContext?.goNamed(
      GameDetailScreen.routeName,
      pathParameters: pathParameters,
    );
  }
}
