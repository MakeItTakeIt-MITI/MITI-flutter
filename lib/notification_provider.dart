import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_provider.g.dart';

final fcmTokenProvider = StateProvider<String?>((ref) => null);

@Riverpod(keepAlive: true)
class Notification extends _$Notification {
  FlutterLocalNotificationsPlugin? notificationsPlugin;

  @override
  void build() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      // TODO: If necessary send token to application server.
      log('refresh fcm token ${fcmToken}');
      ref.read(fcmTokenProvider.notifier).update((state) => fcmToken);
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    //
    // /// 포그라운드 상태에서 알림 수신 시 listen
    // FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
    //   log('onMessage = $message');
    //
    //   if (message != null) {
    //     if (message.notification != null) {
    //       logger.e(message.notification!.title);
    //       logger.e(message.notification!.body);
    //       logger.e(message.data["click_action"]);
    //     }
    //   }
    //
    //   RemoteNotification? notification = message?.notification;
    //
    //     if (notification != null) {
    //       final flutterLocalNotificationsPlugin =
    //           ref.read(notificationProvider.notifier).getNotification;
    //       flutterLocalNotificationsPlugin?.show(
    //           notification.hashCode,
    //           notification.title,
    //           notification.body,
    //           const NotificationDetails(
    //             android: AndroidNotificationDetails(
    //               'high_importance_channel',
    //               'high_importance_notification',
    //               importance: Importance.max,
    //             ),
    //             iOS: DarwinNotificationDetails(),
    //           ),
    //           payload: message?.data['test_paremeter1']);
    //
    //       print("수신자 측 메시지 수신");
    //     }
    // });
    //
    // /// 백그라운드 상태에서 알림을 클릭 시 listen
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
    //   log('onMessageOpenedApp = $message');
    //
    //   if (message != null) {
    //     if (message.notification != null) {
    //       logger.e(message.notification!.title);
    //       logger.e(message.notification!.body);
    //       logger.e(message.data["click_action"]);
    //     }
    //   }
    // });
    //
    //
    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? message) {
    //   if (message != null) {
    //     if (message.notification != null) {
    //       logger.e(message.notification!.title);
    //       logger.e(message.notification!.body);
    //       logger.e(message.data["click_action"]);
    //     }
    //   }
    // });
  }

  void setNotificationPlugin(
      FlutterLocalNotificationsPlugin notificationsPlugin) {
    this.notificationsPlugin = notificationsPlugin;
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    log('설정');
  }

  FlutterLocalNotificationsPlugin? get getNotification => notificationsPlugin;
}
