import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/permission_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )
      ..forward()
      ..addListener(() {
        if (controller.isCompleted) {
          controller.repeat();
        }
      });
    startApp();
  }

  Future<void> startApp() async {
    final storage = ref.read(secureStorageProvider);
    final first = await storage.read(key: 'firstJoin');
    if (first == null) {
      if (mounted) {
        context.goNamed(PermissionScreen.routeName);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref.read(authProvider.notifier).autoLogin(context: context);
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
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
              child: LoadingAnimation(controller: controller,),
            )
          ],
        ),
      ),
    );
  }
}


class LoadingAnimation extends StatelessWidget {
  final AnimationController controller;
  const LoadingAnimation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        // log('controller.value = ${controller.value}');
        return Transform.translate(
          offset: Offset(controller.value * 80.w, 0),
          child: Container(
            width: 20.w,
            color: const Color(0xFF969696),
          ),
        );
      },
    );
  }
}
