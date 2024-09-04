import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/court/view/court_detail_screen.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/permission_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common/provider/router_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final Box<bool> permissionBox;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startApp();
    });
  }

  Future<void> startApp() async {
    permissionBox = Hive.box('permission');
    final display = permissionBox.get('permission');
    // final display = await _permission();
    await _initLocalNotification();
    if (display == null) {
      if (mounted) {
        context.goNamed(PermissionScreen.routeName);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref.read(authProvider.notifier).autoLogin(context: context);
      });
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => (CourtSearchListScreen(
                  )),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    log('알람 클릭');
    final Map<String, String> pathParameters = {'courtId': '3'};

    shellNavKey.currentState!.context.goNamed(
      CourtSearchListScreen.routeName,
      pathParameters: pathParameters,
    );

    // context.goNamed(LoginScreen.routeName);
  }

  Future<void> _initLocalNotification() async {
    // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();
    //
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('drawable/icon');
    //
    // final DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings(
    //         onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    //
    // final InitializationSettings initializationSettings =
    //     InitializationSettings(
    //         android: initializationSettingsAndroid,
    //         iOS: initializationSettingsDarwin);
    //
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);



    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.none,
            priority: Priority.high,
            color: Color.fromARGB(255, 255, 0, 0),
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    final flutterLocalNotificationsPlugin = ref.read(notificationProvider.notifier).getNotification;

    await flutterLocalNotificationsPlugin?.show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');

    // FlutterLocalNotificationsPlugin _localNotification =
    // FlutterLocalNotificationsPlugin();
    //
    // await _localNotification.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    //
    // AndroidInitializationSettings initSettingsAndroid =
    // const AndroidInitializationSettings('@mipmap/ic_launcher');
    // DarwinInitializationSettings initSettingsIOS =
    // const DarwinInitializationSettings(
    //   // requestSoundPermission: false,
    //   // requestBadgePermission: false,
    //   // requestAlertPermission: false,
    // );
    //
    // InitializationSettings initSettings = InitializationSettings(
    //   android: initSettingsAndroid,
    //   iOS: initSettingsIOS,
    // );
    // await _localNotification.initialize(
    //   initSettings,
    // );
  }

  //
  // Future<bool> _permission() async {
  //   var requestStatus = await Permission.location.request();
  //   var status = await Permission.location.status;
  //   log('requestStatus = $requestStatus, status = $status');
  //
  //   if (requestStatus.isPermanentlyDenied ||
  //       status.isPermanentlyDenied) {
  //     // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
  //     print("isPermanentlyDenied");
  //     return false;
  //   } else if (status.isRestricted) {
  //     // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
  //     print("isRestricted");
  //     return false;
  //   } else if (status.isDenied) {
  //     // 권한 요청 거절
  //     print("isDenied");
  //     return false;
  //   }
  //   print("requestStatus ${requestStatus.name}");
  //   print("status ${status.name}");
  //   // final storage = ref.read(secureStorageProvider);
  //   // await storage.write(key: 'firstJoin', value: 'true');
  //   return true;
  // }

  @override
  void dispose() {
    super.dispose();
  }

  double shake(double value) =>
      2 * (0.5 - (0.5 - Curves.bounceOut.transform(value)).abs());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 320.h),
            Container(
              width: 88.w,
              height: 28.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo/MITI.png'),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Make it, Take it!',
              style: TextStyle(
                fontSize: 14.sp,
                letterSpacing: -0.25.sp,
                fontWeight: FontWeight.w400,
                height: 22 / 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.h),
            Container(
              width: 100.w,
              height: 2.h,
              decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
              alignment: Alignment.centerLeft,
              child: const LoadingAnimation(),
            )
          ],
        ),
      ),
    );
  }
}

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({
    super.key,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _startWidth;
  late final Animation<double> _offset;
  late final Animation<double> _endWidth;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )
      ..forward()
      ..addListener(() {
        if (_controller.isCompleted) {
          _controller.repeat();
        }
      });

    /// 로딩 bar
    /// 1. width 를 늘리기
    /// 2. bar를 이동 끝까지 이동
    /// 3. width 를 줄이기

    _startWidth = Tween<double>(
      begin: 0.0,
      end: 20.w,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );
    _offset = Tween<double>(
      begin: 0.w,
      end: 100.w,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 1, curve: Curves.easeIn),
      ),
    );
    _endWidth = Tween<double>(
      begin: 0.w,
      end: 20.w,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1, curve: Curves.easeIn),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(_offset.value, 0),
          child: Container(
            width: _startWidth.value - _endWidth.value,
            color: const Color(0xFF969696),
          ),
        );
      },
    );
  }
}
