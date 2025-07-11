import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/env/environment.dart';
import 'package:miti/splash_screen.dart';

import '../provider/router_provider.dart';


class DeepLinkService {
  static const _platform = MethodChannel('app/deeplink');

  void initialize() {
    _platform.setMethodCallHandler(_handleMethod);
  }

  void dispose() {
    // Method Channel은 별도 dispose가 필요하지 않음
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'handleDeepLink':
        final String url = call.arguments;
        _processDeepLink(url);
        break;
      default:
        print('Unknown method ${call.method}');
    }
  }

  void _processDeepLink(String url) {
    print('Received deep link: $url');

    final uri = Uri.parse(url);
    print('Received deep link uri = $uri');
    print('Received scheme= ${uri.scheme}');

    final redirectUri = _extractRedirectUri(uri);
    if (redirectUri.isNotEmpty) {
      _navigateToSplash(redirectUri);
    }
  }

  String _extractRedirectUri(Uri uri) {
    // 카카오 공유 핸들링
    if (uri.scheme == 'kakao${Environment.kakaoNativeAppKey}') {
      print('kakao${Environment.kakaoNativeAppKey}');

      final kakaoUriString = uri.queryParameters['url'];
      if (kakaoUriString != null) {
        final kakaoUri = Uri.parse(kakaoUriString);
        print('kakaoUri = $kakaoUri');
        return _buildRedirectUri(kakaoUri);
      }
    }
    // Custom Scheme 처리: miti://games/123?userId=456&tab=review
    else if (uri.scheme == 'miti') {
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

  void _navigateToSplash(String redirectUri) {
    final queryParameters = {'redirectUri': redirectUri};

    rootNavKey.currentContext?.goNamed(
      SplashScreen.routeName,
      queryParameters: queryParameters,
    );
  }
}
