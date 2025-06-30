import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class NaverMapUtil {
  /// 네이버 지도 앱 설치 여부 확인
  static Future<bool> isNaverMapAppInstalled() async {
    try {
      // Android는 네이버 지도 패키지 확인
      if (Platform.isAndroid) {
        const String naverMapUrl = 'nmap://map?appname=test';
        return await canLaunchUrl(Uri.parse(naverMapUrl));
      }
      // iOS는 URL scheme 확인
      else if (Platform.isIOS) {
        const String naverMapUrl = 'nmap://map?appname=test';
        return await canLaunchUrl(Uri.parse(naverMapUrl));
      }
      return false;
    } catch (e) {
      print('네이버 지도 앱 설치 확인 오류: $e');
      return false;
    }
  }

  /// 앱 설치 여부에 따른 경로 검색
  static Future<void> searchRoute({
    required String destinationAddress,
    double? destinationLat,
    double? destinationLng,
    PathType pathType = PathType.publicTransport,
  }) async {
    try {
      // 1. 먼저 네이버 지도 앱 설치 여부 확인
      final bool isAppInstalled = await isNaverMapAppInstalled();

      if (isAppInstalled) {
        print('네이버 지도 앱이 설치되어 있음 - 앱으로 실행');
        // 앱이 있으면 앱으로 실행
        await _launchWithApp(
          destinationAddress: destinationAddress,
          destinationLat: destinationLat,
          destinationLng: destinationLng,
          pathType: pathType,
        );
      } else {
        print('네이버 지도 앱이 설치되어 있지 않음 - 웹 검색으로 실행');
        // 앱이 없으면 웹 검색으로 실행
        await searchOnNaverMapWeb(destinationAddress);
      }
    } catch (e) {
      print('경로 검색 오류: $e');
      // 오류 발생 시 웹 검색으로 대체
      await searchOnNaverMapWeb(destinationAddress);
    }
  }

  /// 앱으로 경로 검색 실행 (내부 함수)
  static Future<void> _launchWithApp({
    required String destinationAddress,
    double? destinationLat,
    double? destinationLng,
    PathType pathType = PathType.publicTransport,
  }) async {
    try {
      // 웹앱 방식 우선 시도
      final double defaultStartLat = 37.5665; // 서울시청
      final double defaultStartLng = 126.9780;

      final Map<String, String> params = {
        'app': 'Y',
        'version': '7',
        'appMenu': 'route',
        'menu': 'route',
        'routeType': '0', // 추천
        'pathType': pathType.value.toString(),
        'routeOpt': '1',
        'slat': defaultStartLat.toString(),
        'slng': defaultStartLng.toString(),
        'sText': Uri.encodeComponent('현재 위치'),
        'elat': destinationLat?.toString() ?? '',
        'elng': destinationLng?.toString() ?? '',
        'eText': Uri.encodeComponent(destinationAddress),
      };

      final String queryString = params.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');

      final String webAppUrl =
          'https://app.map.naver.com/launchApp/?$queryString';

      // 웹앱 URL로 실행 시도
      final bool webAppLaunched = await launchUrl(Uri.parse(webAppUrl),
          mode: LaunchMode.externalApplication);

      if (!webAppLaunched) {
        // 웹앱이 안되면 네이티브 URL Scheme 시도
        await _launchWithNativeScheme(
          destinationAddress: destinationAddress,
          destinationLat: destinationLat,
          destinationLng: destinationLng,
          pathType: pathType,
        );
      }
    } catch (e) {
      print('앱 실행 오류: $e');
      // 앱 실행 실패 시 웹 검색으로 대체
      await searchOnNaverMapWeb(destinationAddress);
    }
  }

  /// 네이티브 URL Scheme으로 실행 (내부 함수)
  static Future<void> _launchWithNativeScheme({
    required String destinationAddress,
    double? destinationLat,
    double? destinationLng,
    PathType pathType = PathType.publicTransport,
  }) async {
    try {
      String actionPath;
      switch (pathType) {
        case PathType.car:
          actionPath = 'route/car';
          break;
        case PathType.walk:
          actionPath = 'route/walk';
          break;
        case PathType.bicycle:
          actionPath = 'route/bicycle';
          break;
        case PathType.publicTransport:
        default:
          actionPath = 'route/public';
          break;
      }

      String nativeUrl;
      if (destinationLat != null && destinationLng != null) {
        nativeUrl =
            'nmap://$actionPath?dlat=$destinationLat&dlng=$destinationLng&dname=${Uri.encodeComponent(destinationAddress)}&appname=com.yourapp.package';
      } else {
        nativeUrl =
            'nmap://search?query=${Uri.encodeComponent(destinationAddress)}&appname=com.yourapp.package';
      }

      await launchUrl(Uri.parse(nativeUrl),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      print('네이티브 스키마 실행 오류: $e');
      // 네이티브 스키마 실패 시 웹 검색으로 대체
      await searchOnNaverMapWeb(destinationAddress);
    }
  }

  /// 단순 네이버 지도 웹 검색
  static Future<void> searchOnNaverMapWeb(String address) async {
    try {
      final String webSearchUrl =
          'https://map.naver.com/p/search/${Uri.encodeComponent(address)}';
      await launchUrl(Uri.parse(webSearchUrl),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      print('네이버 지도 웹 검색 오류: $e');
    }
  }
}

// 열거형 정의
enum RouteType {
  recommended(0), // 추천
  free(1), // 무료 우선
  shortest(2); // 최단 거리

  const RouteType(this.value);

  final int value;
}

enum PathType {
  car(0), // 자동차
  publicTransport(1), // 대중교통
  walk(2), // 도보
  bicycle(3); // 자전거 (웹앱에서는 지원 안 될 수 있음)

  const PathType(this.value);

  final int value;
}

enum RoutePathType {
  car,
  publicTransport,
  walk,
  bicycle,
}
