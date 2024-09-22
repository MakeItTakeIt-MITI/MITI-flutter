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
import 'package:miti/court/view/court_search_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(authProvider.notifier).autoLogin(context: context);
    });

    // permissionBox = Hive.box('permission');
    // final display = permissionBox.get('permission');
    // if (display == null) {
    //   if (mounted) {
    //     context.goNamed(PermissionScreen.routeName);
    //   }
    // } else {
    //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //     ref.read(authProvider.notifier).autoLogin(context: context);
    //   });
    // }
  }

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
