import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

import '../../common/provider/router_provider.dart';
import '../../util/util.dart';


class LogoVideoWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final bool autoPlay;
  final bool loop;

  const LogoVideoWidget({
    super.key,
    this.width,
    this.height,
    this.autoPlay = true,
    this.loop = true,
  });

  @override
  State<LogoVideoWidget> createState() => _LogoVideoWidgetState();
}

class _LogoVideoWidgetState extends State<LogoVideoWidget> with RouteAware {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();
    log('=== LogoVideoWidget initState ===');
    _initializeVideo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    log('=== LogoVideoWidget dispose ===');
    _videoController.dispose();
    super.dispose();
  }

  // 🔴 다른 화면으로 push할 때 - 비디오 정지
  @override
  void didPushNext() {
    log('🔴 다른 화면으로 이동 - 비디오 정지');
    if (_isVideoInitialized && !_hasVideoError) {
      _videoController.pause();
    }
  }

  // 🟢 다른 화면에서 pop으로 돌아올 때 - 처음부터 재생
  @override
  void didPopNext() {
    log('🟢 화면으로 돌아옴 - 처음부터 재생');
    if (_isVideoInitialized && !_hasVideoError && widget.autoPlay) {
      _videoController.seekTo(Duration.zero);
      _videoController.play();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      log('비디오 초기화 시작');
      _videoController = VideoPlayerController.asset('assets/mp4/LOGO.mp4');
      await _videoController.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        log('비디오 초기화 완료');

        if (widget.loop) {
          _videoController.setLooping(true);
        }

        if (widget.autoPlay) {
          log('초기 자동 재생 시작');
          _videoController.play();
        }
      }
    } catch (e) {
      log('비디오 초기화 실패: $e');
      if (mounted) {
        setState(() {
          _hasVideoError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 비디오 로딩 실패 시 기본 로고 fallback
    if (_hasVideoError) {
      return SvgPicture.asset(
        AssetUtil.getAssetPath(type: AssetType.logo, name: 'MITI'),
        width: widget.width ?? 80.w,
        height: widget.height ?? 42.h,
      );
    }

    // 비디오 로딩 중
    if (!_isVideoInitialized) {
      return Container(
        width: widget.width ?? 80.w,
        height: widget.height ?? 42.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          child: SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              color: Colors.white54,
              strokeWidth: 1.5.w,
            ),
          ),
        ),
      );
    }

    // 비디오 재생
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _videoController.value.size.width,
          height: _videoController.value.size.height,
          child: VideoPlayer(_videoController),
        ),
      ),
    );
  }
}
