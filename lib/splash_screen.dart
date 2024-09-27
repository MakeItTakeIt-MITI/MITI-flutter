import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif_view/gif_view.dart';
import 'package:lottie/lottie.dart';

import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/theme/color_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(onFinish: () {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startApp();
    });
  }

  Future<void> startApp() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          ref.read(authProvider.notifier).autoLogin(context: context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.black,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/splash.json',
          height: 84.h,
          width: 160.w,
          fit: BoxFit.fill,
          repeat: false,
        ),
      ),
    );
  }
}
