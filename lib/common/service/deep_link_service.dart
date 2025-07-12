import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:miti/env/environment.dart';
import 'package:miti/splash_screen.dart';

import '../provider/router_provider.dart';

class DeepLinkService {
  static const _deeplinkChannel = MethodChannel('app/deeplink');
  static const _kakaoShareChannel = MethodChannel('app/kakao_share');

  void initialize() {
    _deeplinkChannel.setMethodCallHandler(_handleDeepLinkMethod);
    _kakaoShareChannel.setMethodCallHandler(_handleKakaoShareMethod);

    // 카카오 공유 스트림 리스너도 설정 (이중 안전장치)
    _initializeKakaoShareStream();
  }

  void dispose() {
    // Method Channel은 별도 dispose가 필요하지 않음
  }

  // 🔥 카카오 공유 전용 핸들러
  Future<dynamic> _handleKakaoShareMethod(MethodCall call) async {
    switch (call.method) {
      case 'handleKakaoShare':
        final Map<String, dynamic> urlData =
            Map<String, dynamic>.from(call.arguments);
        final String url = urlData['url'];
        print('🎯 Kakao Share URL received: $url');
        await _processKakaoShare(url);
        break;
      default:
        print('Unknown Kakao Share method: ${call.method}');
    }
  }

  // 일반 딥링크 핸들러
  Future<dynamic> _handleDeepLinkMethod(MethodCall call) async {
    switch (call.method) {
      case 'handleDeepLink':
        final String url = call.arguments;
        print('🔗 Deep Link received: $url');
        await _processDeepLink(url);
        break;
      default:
        print('Unknown DeepLink method: ${call.method}');
    }
  }

  // 카카오 공유 스트림 리스너 (이중 안전장치)
  void _initializeKakaoShareStream() {
    try {
      // kakaoSchemeStream을 사용한 추가 처리
      // 이는 iOS에서 놓친 경우를 대비한 백업 메커니즘
      kakaoSchemeStream.listen((url) {
        print('🔄 Kakao Scheme Stream: $url');
        if (url != null) _processKakaoShare(url);
      }, onError: (error) {
        print('❌ Kakao Scheme Stream Error: $error');
      });
    } catch (e) {
      print('⚠️ Failed to initialize Kakao Scheme Stream: $e');
    }
  }

  // 🎯 카카오 공유 처리 (분리된 메소드)
  Future<void> _processKakaoShare(String url) async {
    try {
      print('📤 Processing Kakao Share: $url');

      final uri = Uri.parse(url);

      // 카카오 공유 URL인지 확인
      if (uri.scheme == 'kakao${Environment.kakaoNativeAppKey}' &&
          uri.host == 'kakaolink') {
        final redirectUri = _extractKakaoShareRedirectUri(uri);
        if (redirectUri.isNotEmpty) {
          print('🎯 Navigating to: $redirectUri');
          await _navigateToSplash(redirectUri);
        }
      }
    } catch (e) {
      print('❌ Error processing Kakao Share: $e');
    }
  }

  // 일반 딥링크 처리
  Future<void> _processDeepLink(String url) async {
    try {
      print('🔗 Processing Deep Link: $url');

      final uri = Uri.parse(url);
      print(
          '📍 URI details - scheme: ${uri.scheme}, host: ${uri.host}, path: ${uri.path}');

      final redirectUri = _extractRedirectUri(uri);
      if (redirectUri.isNotEmpty) {
        print('🎯 Navigating to: $redirectUri');
        await _navigateToSplash(redirectUri);
      }
    } catch (e) {
      print('❌ Error processing Deep Link: $e');
    }
  }

  // 카카오 공유 전용 리다이렉트 URI 추출
  String _extractKakaoShareRedirectUri(Uri uri) {
    final kakaoUriString = uri.queryParameters['url'];
    if (kakaoUriString != null && kakaoUriString.isNotEmpty) {
      final kakaoUri = Uri.parse(kakaoUriString);
      print('🎯 Extracted Kakao URI: $kakaoUri');
      return _buildRedirectUri(kakaoUri);
    }
    return '';
  }

  // 일반 리다이렉트 URI 추출
  String _extractRedirectUri(Uri uri) {
    // Custom Scheme 처리: miti://games/123?userId=456&tab=review
    if (uri.scheme == 'miti') {
      return _buildRedirectUri(uri, isCustomScheme: true);
    }
    // HTTPS 링크 처리: https://www.makeittakeit.kr/games/123?userId=456&tab=review
    else if (uri.scheme == 'https') {
      return _buildRedirectUri(uri);
    }

    return '';
  }

  String _buildRedirectUri(Uri uri, {bool isCustomScheme = false}) {
    String redirectUri = '';

    if (isCustomScheme) {
      // Custom Scheme: miti://games/123
      final path = uri.host; // 'games' 또는 'courts'
      final segments = uri.pathSegments;

      if (segments.isNotEmpty) {
        redirectUri = '/$path/${segments.join('/')}';
      } else {
        redirectUri = '/$path';
      }
    } else {
      // HTTPS: https://www.makeittakeit.kr/games/123
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        redirectUri = '/${segments.join('/')}';
      }
    }

    // 쿼리 파라미터 추가
    if (uri.queryParameters.isNotEmpty) {
      final queryString = uri.queryParameters.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      redirectUri += '?$queryString';
    }

    return redirectUri;
  }

  // 비동기 네비게이션 (코루틴 스타일)
  Future<void> _navigateToSplash(String redirectUri) async {
    try {
      // 현재 컨텍스트가 유효한지 확인
      if (rootNavKey.currentContext == null) {
        print('⚠️ Navigation context not available, waiting...');

        // 최대 3초간 컨텍스트 대기 (코루틴 timeout 패턴)
        int attempts = 0;
        while (rootNavKey.currentContext == null && attempts < 30) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }

        if (rootNavKey.currentContext == null) {
          print('❌ Navigation context still not available after 3 seconds');
          return;
        }
      }

      final queryParameters = {'redirectUri': redirectUri};

      rootNavKey.currentContext!.goNamed(
        SplashScreen.routeName,
        queryParameters: queryParameters,
      );

      print('✅ Navigation completed successfully');
    } catch (e) {
      print('❌ Navigation failed: $e');
    }
  }
}
