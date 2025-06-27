import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/env/environment.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/notification/model/push_model.dart';
import 'package:miti/notification/view/notification_detail_screen.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/splash_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../common/model/entity_enum.dart';
import '../common/provider/provider_observer.dart';
import '../common/provider/router_provider.dart';
import '../court/view/court_detail_screen.dart';
import '../firebase_options.dart';
import '../notification/provider/notification_provider.dart';
import '../notification/view/notification_screen.dart';
import '../post/repository/search_history_repository.dart';
import '../util/util.dart';

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
    // & 기준으로 문자열을 분할
    List<String> parts = details.payload!.split('&');

    // Map에 키-값 쌍 추가
    Map<String, String> resultMap = {};

    for (String part in parts) {
      List<String> keyValue = part.split('=');
      if (keyValue.length == 2) {
        resultMap[keyValue[0]] = keyValue[1];
      }
    }

    final topicEnum =
        PushNotificationTopicType.stringToEnum(value: resultMap['topic']!);
    final model = PushDataModel(
        pushId: resultMap['pushId']!,
        topic: topicEnum,
        gameId: resultMap['gameId']);
  }
}

void _backgroundRouting(NotificationResponse details) {
  log('_backgroundRouting = $details');
  rootNavKey.currentContext!.goNamed(NotificationScreen.routeName);
}

void main(List<String> args) async {
  EnvUtil.instance.initialize(environment: BuildEnvironment.development);

  print("Loading environment: .env.dev");
  log("Loading environment: .env.dev");
  await dotenv.load(fileName: ".env.dev");

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
  await Hive.openBox<String>('recentUpdateVersion');

  await SearchHistoryRepository().initialize();

  // Firebase 초기화
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
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  static const platform = MethodChannel('app/deeplink');

  @override
  void initState() {
    super.initState();
    _notificationSetting();
    getFcmToken(ref);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
    initDeepLinks();
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'handleDeepLink':
        final String url = call.arguments;
        _processDeepLink(url);
        break;
      default:
        print('Unknown method ${call.method}');
    }
  }

  void _processDeepLink(String url) {
    print('Received deep link: $url');
    // URL을 파싱하여 필요한 작업 수행
    // 예: 특정 화면으로 이동, 데이터 처리 등
  }

  Future<void> getFcmToken(WidgetRef ref) async {
    String? token;
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    log('FCM Token 가져오기');

    // 플랫폼 별 토큰 가져오기
    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      print("apnToken : $apnsToken");
      if (apnsToken != null) {
        token = await messaging.getToken();
      } else {
        await Future<void>.delayed(
          const Duration(
            seconds: 3,
          ),
        );
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          token = await messaging.getToken();
          ref.read(fcmTokenProvider.notifier).update((state) => token);
        }
      }
    } else {
      token = await messaging.getToken();
    }

    ref.read(fcmTokenProvider.notifier).update((state) => token);
    print("FCM Token: $token");
    log('FCM Token: $token');
  }

  void _notificationSetting() async {
    _localNotificationSetting();
    _fcmSetting();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('uri.path: ${uri.path}');
      debugPrint('uri.fragment: ${uri.fragment}');
      debugPrint('uri.query: ${uri.query}');
      debugPrint('uri.queryParameters: ${uri.queryParameters}');
      if (uri.queryParameters['url'] != null) {
        final paths =
            Uri.parse(uri.queryParameters['url']!).path.substring(1).split('/');
        debugPrint('paths: ${paths}');

        if (paths[0] == 'games') {
          Map<String, String> pathParameters = {'gameId': paths[1]};
          rootNavKey.currentContext!.goNamed(
            GameDetailScreen.routeName,
            pathParameters: pathParameters,
          );
        } else if (paths[0] == 'courts') {
          Map<String, String> pathParameters = {'courtId': paths[1]};
          rootNavKey.currentContext!.goNamed(
            CourtDetailScreen.routeName,
            pathParameters: pathParameters,
          );
        }
      }

      debugPrint('onAppLink: $uri');
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
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
        final gameId = event.data['game_id'];
        final pushId = event.data['push_notification_id'];
        String topic = event.data['topic'];
        final topicEnum = PushNotificationTopicType.stringToEnum(value: topic);
        final model =
            PushDataModel(pushId: pushId, topic: topicEnum, gameId: gameId);
        rootNavKey.currentContext!
            .goNamed(SplashScreen.routeName, extra: model);
        // _handleMessage(gameId, pushId, topicEnum);
      }
    });

    // 앱이 처음 시작될 때 초기 메시지 처리 (앱이 백그라운드에서 실행되었을 때)
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null && message.data.isNotEmpty) {
        await ref.read(authProvider.notifier).autoLogin();
        final gameId = message.data['game_id'];
        final pushId = message.data['push_notification_id'];
        String topic = message.data['topic'];
        log('message.data = ${message.data}');
        final topicEnum = PushNotificationTopicType.stringToEnum(value: topic);
        final model =
            PushDataModel(pushId: pushId, topic: topicEnum, gameId: gameId);
        rootNavKey.currentContext!
            .goNamed(SplashScreen.routeName, extra: model);
        // _handleMessage(gameId, pushId, topicEnum);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      /// fcm이 오면 local notification으로 푸쉬 알람 보여주기
      if (notification != null) {
        String? gameId = message.data['game_id'];
        String? pushId = message.data['push_notification_id'];
        String? topic = message.data['topic'];

        final flutterLocalNotificationsPlugin =
            ref.read(notificationProvider.notifier).getNotification;
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
              payload: "gameId=$gameId&pushId=$pushId&topic=$topic");
        }

        final secureProvider = ref.read(secureStorageProvider);
        final String? storagePushCnt =
            await secureProvider.read(key: 'pushCnt');

        int pushCnt = int.parse(storagePushCnt ?? '-1') + 1;
        AppBadgePlus.updateBadge(pushCnt);

        secureProvider.write(key: 'pushCnt', value: pushCnt.toString());
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
      onDidReceiveNotificationResponse: (details) {
        _foregroundRouting(details);
        if (details.payload != null && details.payload!.isNotEmpty) {
          // & 기준으로 문자열을 분할
          List<String> parts = details.payload!.split('&');

          // Map에 키-값 쌍 추가
          Map<String, String> resultMap = {};

          for (String part in parts) {
            List<String> keyValue = part.split('=');
            if (keyValue.length == 2) {
              resultMap[keyValue[0]] = keyValue[1];
            }
          }

          final topicEnum = PushNotificationTopicType.stringToEnum(
              value: resultMap['topic']!);
          final model = PushDataModel(
              pushId: resultMap['pushId']!,
              topic: topicEnum,
              gameId: resultMap['gameId']);
          _handleMessage(model);
        }
      },
    );

    return localNotification;
  }

  void _handleMessage(PushDataModel model) {
    switch (model.topic) {
      case PushNotificationTopicType.general:
        Map<String, String> pathParameters = {'id': model.pushId.toString()};
        rootNavKey.currentContext!.goNamed(
          NoticeDetailScreen.routeName,
          pathParameters: pathParameters,
          extra: NoticeScreenType.notification,
        );
      case PushNotificationTopicType.game_status_changed:
      case PushNotificationTopicType.new_participation:
      case PushNotificationTopicType.game_fee_changed:
        ref
            .read(pushProvider(pushId: int.parse(model.pushId)).notifier)
            .get(pushId: int.parse(model.pushId));
        Map<String, String> pathParameters = {
          'gameId': model.gameId.toString()
        };
        rootNavKey.currentContext!.goNamed(
          GameDetailScreen.routeName,
          pathParameters: pathParameters,
        );
        break;
      default:
        Map<String, String> pathParameters = {'id': model.pushId.toString()};
        rootNavKey.currentContext!.goNamed(
          NoticeDetailScreen.routeName,
          pathParameters: pathParameters,
          extra: NoticeScreenType.push,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: true,
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
              colorScheme: const ColorScheme(
                brightness: Brightness.dark,
                primary: MITIColor.primary,
                onPrimary: MITIColor.primary,
                secondary: Colors.white,
                onSecondary: Colors.white,
                error: MITIColor.error,
                onError: MITIColor.error,
                surface: MITIColor.gray800,
                onSurface: MITIColor.gray100,
              ),
              pageTransitionsTheme: const PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              }),
              fontFamily: 'Pretendard',
              inputDecorationTheme: InputDecorationTheme(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
    );
  }

  Future<void> fcmPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
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
