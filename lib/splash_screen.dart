import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:video_player/video_player.dart'; // 추가

import 'common/model/entity_enum.dart';
import 'game/view/game_detail_screen.dart';
import 'notification/model/push_model.dart';
import 'notification/provider/notification_provider.dart';
import 'notification/view/notification_detail_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String get routeName => 'splash';
  final String? redirectUri;
  final PushDataModel? pushModel;

  const SplashScreen({
    super.key,
    this.redirectUri,
    this.pushModel,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  bool _isVideoCompleted = false;
  bool _isRoutingReady = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _prepareRouting(); // 비디오와 병렬로 라우팅 준비
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/mp4/main.mp4');
      await _videoController.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        _videoController.play();

        // 비디오 완료 감지
        _videoController.addListener(_onVideoPositionChanged);
      }
    } catch (e) {
      log('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _isVideoCompleted = true; // 에러 시에도 다음 단계로
        });
        _checkAndNavigate();
      }
    }
  }

  void _onVideoPositionChanged() {
    if (!_isVideoCompleted &&
        _videoController.value.position >= _videoController.value.duration) {
      setState(() {
        _isVideoCompleted = true;
      });
      _videoController.pause();
      log("Video completed!");
      _checkAndNavigate();
    }
  }

  Future<void> _prepareRouting() async {
    // FCM 토큰 대기
    await _waitForFCMToken();

    if (mounted) {
      setState(() {
        _isRoutingReady = true;
      });
      log("Routing preparation completed!");
      _checkAndNavigate();
    }
  }

  Future<void> _waitForFCMToken() async {
    int maxRetries = 10; // 최대 10초 대기
    int retryCount = 0;

    while (retryCount < maxRetries) {
      final fcmToken = ref.read(fcmTokenProvider);
      if (fcmToken != null) {
        log("FCM token ready: ${fcmToken.substring(0, 20)}...");
        return;
      }

      log("Waiting for FCM token... retry: $retryCount");
      await Future.delayed(const Duration(seconds: 1));
      retryCount++;
    }

    log("FCM token not received, proceeding anyway...");
  }

  void _checkAndNavigate() {
    // 비디오 완료 && 라우팅 준비 완료 && 아직 네비게이션 안함
    if (_isVideoCompleted && _isRoutingReady && !_isNavigating) {
      _isNavigating = true;
      log("All ready! Starting navigation...");
      _performNavigation();
    }
  }

  void _performNavigation() {
    if (!mounted) return;

    if (widget.redirectUri != null) {
      log("deepLink routing!!!");
      _handleDeepLink(widget.redirectUri!);
    } else if (widget.pushModel != null) {
      log("push routing!!!");
      ref.read(authProvider.notifier).autoLogin();
      _handleMessage(widget.pushModel!);
    } else {
      log("normal routing!!!");
      ref.read(authProvider.notifier).autoLogin(context: context);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoPositionChanged);
    _videoController.dispose();
    super.dispose();
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
        break;
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
      backgroundColor: V2MITIColor.black,
      body: Stack(
        children: [
          _buildVideoWidget(),
          // _buildDebugInfo(), // 개발 중에만 사용
        ],
      ),
    );
  }

  void _handleDeepLink(String deepLink) {
    context.go(deepLink);
  }

  Widget _buildVideoWidget() {
    if (_hasVideoError) {
      return Container(
        color: V2MITIColor.black,
        child: Center(
          child: Icon(
            Icons.video_library,
            color: Colors.white54,
            size: 64.w,
          ),
        ),
      );
    }

    if (!_isVideoInitialized) {
      return Container(
        color: V2MITIColor.black,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2.w,
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController.value.size.width,
          height: _videoController.value.size.height,
          child: VideoPlayer(_videoController),
        ),
      ),
    );
  }

  // 개발 중 상태 확인용 (배포 시 제거)
  Widget _buildDebugInfo() {
    return Positioned(
      bottom: 50.h,
      left: 20.w,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video: ${_isVideoCompleted ? "✅" : "⏳"}',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
            Text(
              'Routing: ${_isRoutingReady ? "✅" : "⏳"}',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
            Text(
              'Navigation: ${_isNavigating ? "✅" : "⏳"}',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
