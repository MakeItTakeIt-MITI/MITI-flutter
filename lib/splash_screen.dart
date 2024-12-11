import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/theme/color_theme.dart';

import 'common/model/entity_enum.dart';
import 'game/view/game_detail_screen.dart';
import 'notification/model/push_model.dart';
import 'notification/provider/notification_provider.dart';
import 'notification/view/notification_detail_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String get routeName => 'splash';
  final PushDataModel? pushModel;

  const SplashScreen({
    super.key,
    this.pushModel,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startApp();
    });
  }

  Future<void> startApp() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 1500), () async {
        final fcmToken = ref.read(fcmTokenProvider);
        if (fcmToken == null) {
          await Future.delayed(const Duration(seconds: 3));
        }
        if (mounted) {
          if (widget.pushModel != null) {
            log("push routing!!!");
            ref.read(authProvider.notifier).autoLogin();
            _handleMessage(widget.pushModel!);
          } else {
            ref.read(authProvider.notifier).autoLogin(context: context);
          }
        }
      });
    });
  }

  void _handleMessage(PushDataModel model) {
    switch (model.topic) {
      case PushNotificationTopicType.general:
        Map<String, String> pathParameters = {'id': model.pushId.toString()};
        context.goNamed(
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
        context.goNamed(
          GameDetailScreen.routeName,
          pathParameters: pathParameters,
        );
        break;
      default:
        Map<String, String> pathParameters = {'id': model.pushId.toString()};
        context.goNamed(
          NoticeDetailScreen.routeName,
          pathParameters: pathParameters,
          extra: NoticeScreenType.push,
        );
    }
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
