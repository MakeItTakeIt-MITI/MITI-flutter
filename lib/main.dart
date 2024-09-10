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
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/env/environment.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'common/provider/provider_observer.dart';
import 'common/provider/router_provider.dart';
import 'common/provider/secure_storage_provider.dart';
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
    // disableBattaryOptimization();
  }

  void _notificationSetting() {
    _localNotificationSetting();

    _fcmSetting();
  }

  // void disableBattaryOptimization() async {
  //   final response =
  //       await DisableBatteryOptimization.showDisableAllOptimizationsSettings(
  //           "Enable Auto Start",
  //           "Follow the steps and enable the auto start of this app",
  //           "Your device has additional battery optimization",
  //           "Follow the steps and disable the optimizations to allow smooth functioning of this app");
  //   if (response != null && response) {
  //     bool? isAutoStartEnabled =
  //         await DisableBatteryOptimization.isAutoStartEnabled;
  //   }
  // }

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
        await flutterLocalNotificationsPlugin?.show(
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

        log('notification.title = ${notification.title}');
        log('notification.body = ${notification.body}');
        // log("수신자 측 메시지 수신");
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
                    foregroundColor:
                        WidgetStateProperty.all(MITIColor.gray800),
                    backgroundColor:
                        WidgetStateProperty.all(MITIColor.primary),
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
