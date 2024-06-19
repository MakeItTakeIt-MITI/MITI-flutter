import 'dart:developer';
import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/env/environment.dart';
import 'package:miti/notification_provider.dart';
import 'common/provider/provider_observer.dart';
import 'common/provider/router_provider.dart';
import 'firebase_options.dart';

//
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void _foregroundRouting(NotificationResponse details) {
  rootNavKey.currentState?.context.goNamed(LoginScreen.routeName);
  log('_foregroundRouting = $details');
}

void _backgroundRouting(NotificationResponse details) {
  log('_backgroundRouting = $details');
}

Future<FlutterLocalNotificationsPlugin> _initLocalNotification() async {
  final FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();

  /// Android 세팅
  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

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

Future<void> getFcmToken() async {
  String? token;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 플랫폼 별 토큰 가져오기
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    token = await messaging.getAPNSToken();
  } else {
    token = await messaging.getToken();
  }

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

  await getFcmToken();
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
    // disableBattaryOptimization();
  }

  void _notificationSetting() {
    _localNotificationSetting();

    _fcmSetting();
  }

  void disableBattaryOptimization() async {
    final response =
        await DisableBatteryOptimization.showDisableAllOptimizationsSettings(
            "Enable Auto Start",
            "Follow the steps and enable the auto start of this app",
            "Your device has additional battery optimization",
            "Follow the steps and disable the optimizations to allow smooth functioning of this app");
    if (response != null && response) {
      bool? isAutoStartEnabled =
          await DisableBatteryOptimization.isAutoStartEnabled;
    }
  }

  void _fcmSetting() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((event) {});

    FirebaseMessaging.onMessage.listen((event) {});

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        final flutterLocalNotificationsPlugin =
            ref.read(notificationProvider.notifier).getNotification;
        flutterLocalNotificationsPlugin?.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'high_importance_notification',
                importance: Importance.max,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            payload: message.data['test_paremeter1']);

        print("수신자 측 메시지 수신");
      }
    });

    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    log('remoteMessage = $message');
    if (message != null) {
      // 액션 부분 -> 파라미터는 message.data['test_parameter1'] 이런 방식으로...
      _handleMessage(message);
    }
  }

  void _handleMessage(RemoteMessage message) {
    rootNavKey.currentState?.context.goNamed(LoginScreen.routeName);
  }

  void _localNotificationSetting() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final notification = await _initLocalNotification();
      ref
          .read(notificationProvider.notifier)
          .setNotificationPlugin(notification);
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final router = ref.read(routerProvider);
    ref.read(notificationProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'MITI',
          builder: (context, child) {
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!);
          },
          theme: ThemeData(
              // colorScheme: ColorScheme(
              //     brightness: Brightness.dark,
              //     primary: Colors.black,
              //     onPrimary: Colors.black,
              //     secondary: Colors.white,
              //     onSecondary: Colors.white,
              //     error: Colors.black,
              //     onError: Colors.black,
              //     background: Colors.white,
              //     onBackground: Colors.white,
              //     surface: Colors.black,
              //     onSurface: Colors.black),
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
                hintStyle: TextStyle(
                  color: const Color(0xFF969696),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.25.sp,
                  height: 24 / 16,
                ),
                fillColor: const Color(0xFFF7F7F7),
                filled: true,
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFFFFF),
                      letterSpacing: -0.25.sp,
                      // height: 22 / 14,
                    )),
                    foregroundColor:
                        MaterialStateProperty.all(const Color(0xFFFFFFFF)),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF4065F6)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                      ),
                    ),
                    minimumSize:
                        MaterialStateProperty.all(Size(double.infinity, 48.h)),
                    maximumSize:
                        MaterialStateProperty.all(Size(double.infinity, 48.h))),
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
