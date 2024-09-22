import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif_view/gif_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/court/view/court_search_screen.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/permission_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/util/util.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common/provider/router_provider.dart';

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
    _controller = GifController(onFinish: (){
      log("AAA");
    });
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
        child: GifView.asset(
          controller: _controller,
          AssetUtil.getAssetPath(
              type: AssetType.gif, name: 'splash', extension: 'gif'),
          height: 84.h,
          width: 160.w,
          fit: BoxFit.fill,
          frameRate: 60, // default is 15 FPS
        )
      ),
    );
  }
}
