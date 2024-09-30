import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/env/environment.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/view/profile_screen.dart';
import 'common/model/entity_enum.dart';
import 'common/provider/provider_observer.dart';
import 'common/provider/router_provider.dart';
import 'common/provider/secure_storage_provider.dart';
import 'firebase_options.dart';
import 'notification/provider/widget/unconfirmed_provider.dart';
import 'notification/view/notification_screen.dart';

//
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log("background push data ${message.data}");
  log("Handling a background category: ${message.category}");
}

void _foregroundRouting(NotificationResponse details) async {
  /// foreground 상태일 때 만 fcm 알림 내용 받기 가능
  /// terminated, background 상태일 때는 null
  log('_foregroundRouting = $details');
  log("details.payload = ${details.payload}");
  if (details.payload != null && details.payload!.isNotEmpty) {
    List<String> params = details.payload!.split("&");
    final id = params[0].split("=").length > 1 ? params[0].split("=")[1] : null;
    final topic =
        params[1].split("=").length > 1 ? params[1].split("=")[1] : null;

    final topicEnum = PushNotificationTopicType.stringToEnum(value: topic!);
    _handleMessage(id, topicEnum);
  }
}

void _backgroundRouting(NotificationResponse details) {
  log('_backgroundRouting = $details');
  rootNavKey.currentContext!.goNamed(NotificationScreen.routeName);
}

void _handleMessage(String? id, PushNotificationTopicType topic) {
  switch (topic) {
    case PushNotificationTopicType.general:
      rootNavKey.currentContext!.goNamed(NotificationScreen.routeName);
    case PushNotificationTopicType.game_status_changed:
    case PushNotificationTopicType.new_participation:
    case PushNotificationTopicType.game_fee_changed:
      Map<String, String> pathParameters = {'gameId': id.toString()};
      rootNavKey.currentContext!.goNamed(
        GameDetailScreen.routeName,
        pathParameters: pathParameters,
      );
      break;
    default:
      rootNavKey.currentContext!.goNamed(NotificationScreen.routeName);
  }
}

Future<FlutterLocalNotificationsPlugin> _initLocalNotification() async {
  final FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();

  /// Android 세팅
  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_notification');

  /// IOS 세팅
  const initSettingsIOS = DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await localNotification.initialize(
    initSettings,
    onDidReceiveBackgroundNotificationResponse: _backgroundRouting,
    onDidReceiveNotificationResponse: _foregroundRouting,
  );

  return localNotification;
}

Future<void> getFcmToken(WidgetRef ref) async {
  String? token;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  log('FCM Token 가져오기');

  // 플랫폼 별 토큰 가져오기
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final apnToken = await messaging.getAPNSToken();
    print("apnToken : $apnToken");
    token = await messaging.getToken();
  } else {
    token = await messaging.getToken();
  }
  ref.read(fcmTokenProvider.notifier).update((state) => token);
  print("FCM Token: $token");
  log('FCM Token: $token');
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('ko');
  await NaverMapSdk.instance.initialize(clientId: Environment.naverMapClientId);
  KakaoSdk.init(
    nativeAppKey: Environment.kakaoNativeAppKey,
    javaScriptAppKey: Environment.kakaoJavaScriptAppKey,
  );
  await Hive.initFlutter();
  await Hive.openBox<bool>('permission');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      observers: [
        CustomProviderObserver(),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _notificationSetting();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getFcmToken(ref);
    });
  }

  void _notificationSetting() {
    _localNotificationSetting();
    _fcmSetting();
  }

  void _fcmSetting() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    /// 백그라운드 메시지 푸쉬 올 때
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// 백그라운드에서 메시지 푸쉬를 열 때
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      log('onMessageOpenedApp');
      if (mounted) {
        final id = event.data['id'];
        String topic = event.data['topic'];
        final topicEnum = PushNotificationTopicType.stringToEnum(value: topic);
        _handleMessage(id, topicEnum);
      }
    });

    // 앱이 처음 시작될 때 초기 메시지 처리 (앱이 백그라운드에서 실행되었을 때)
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null && message.data.isNotEmpty) {
        await ref.read(authProvider.notifier).autoLogin();
        final id = message.data['id'];
        String topic = message.data['topic'];
        final topicEnum = PushNotificationTopicType.stringToEnum(value: topic);
        _handleMessage(id, topicEnum);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      ref.read(unconfirmedProvider.notifier).update((s) => true);
      RemoteNotification? notification = message.notification;

      /// fcm이 오면 local notification으로 푸쉬 알람 보여주기
      if (notification != null) {
        String? id = message.data['id'];
        String? topic = message.data['topic'];

        final flutterLocalNotificationsPlugin =
            ref.read(notificationProvider.notifier).getNotification;
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
            payload: "id=$id&topic=$topic");

        log('notification.title = ${notification.title}');
        log('notification.body = ${notification.body}');
        // log("수신자 측 메시지 수신");
      }
    });
  }

  void _localNotificationSetting() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final notification = await _initLocalNotification();
      ref
          .read(notificationProvider.notifier)
          .setNotificationPlugin(notification);
    });
  }

  void _handleMessage(String? id, PushNotificationTopicType topic) {
    switch (topic) {
      case PushNotificationTopicType.general:
        rootNavKey.currentContext!.goNamed(NotificationScreen.routeName);
      case PushNotificationTopicType.game_status_changed:
      case PushNotificationTopicType.new_participation:
      case PushNotificationTopicType.game_fee_changed:
        Map<String, String> pathParameters = {'gameId': id.toString()};
        rootNavKey.currentContext!.goNamed(
          GameDetailScreen.routeName,
          pathParameters: pathParameters,
        );
        break;
      default:
        rootNavKey.currentContext!.goNamed(NotificationScreen.routeName);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final router = ref.read(routerProvider);
    // ref.read(notificationProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[
            Locale('ko', ''),
          ],
          title: 'MITI',
          builder: (context, child) {
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!);
          },
          theme: ThemeData(
              // splashFactory: InkSplash(
              //   controller: controller,
              //   referenceBox: referenceBox,
              //   textDirection: TextDirection.ltr,
              //   color: const Color(0xFF404040),
              //   radius: 8.r
              // ),
              colorScheme: const ColorScheme(
                brightness: Brightness.dark,
                primary: MITIColor.primary,
                onPrimary: MITIColor.primary,
                secondary: Colors.white,
                onSecondary: Colors.white,
                error: MITIColor.error,
                onError: MITIColor.error,
                background: MITIColor.gray800,
                onBackground: MITIColor.gray800,
                surface: MITIColor.gray800,
                onSurface: MITIColor.gray800,
              ),
              pageTransitionsTheme: const PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              }),
              // colorScheme: ColorScheme(background: Colors.white, brightness: null, primary: null, onPrimary: null, secondary: null, onSecondary: null, error: null, onError: null, onBackground: null, surface: null, onSurface: null,),
              fontFamily: 'Pretendard',
              inputDecorationTheme: InputDecorationTheme(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                // constraints: BoxConstraints.loose(Size(double.infinity, 58.h)),
                hintStyle: MITITextStyle.md.copyWith(color: MITIColor.gray500),
                fillColor: MITIColor.gray700,
                filled: true,
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                      MITITextStyle.mdBold.copyWith(
                        color: MITIColor.gray800,
                      ),
                    ),
                    foregroundColor: WidgetStateProperty.all(MITIColor.gray800),
                    backgroundColor: WidgetStateProperty.all(MITIColor.primary),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                      ),
                    ),
                    minimumSize:
                        WidgetStateProperty.all(Size(double.infinity, 48.h)),
                    maximumSize:
                        WidgetStateProperty.all(Size(double.infinity, 48.h))),
              )),
          routerConfig: router,
        );
      },
      // child: const HomeScreen(), // LoginScreen(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
