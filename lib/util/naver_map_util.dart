
import 'package:url_launcher/url_launcher.dart';

class NaverMapUtil {
  /// 주소로 네이버 지도에서 경로 검색
  static Future<void> searchRoute(String destination) async {
    try {
      // 1. 주소 검색으로 지도 열기
      final String searchUrl = 'nmap://search?query=${Uri.encodeComponent(destination)}&appname=com.yourapp.package';

      // 2. 웹 버전
      final String webUrl = 'https://map.naver.com/p/search/${Uri.encodeComponent(destination)}';

      if (await canLaunchUrl(Uri.parse(searchUrl))) {
        await launchUrl(Uri.parse(searchUrl), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('네이버 지도 실행 오류: $e');
    }
  }

  /// 좌표를 알고 있을 때 정확한 경로 검색
  static Future<void> searchRouteWithCoordinates({
    required String destination,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // 대중교통 경로 검색 (목적지만 지정, 출발지는 현재 위치)
      final String routeUrl = 'nmap://route/public?dlat=$latitude&dlng=$longitude&dname=${Uri.encodeComponent(destination)}&appname=com.yourapp.package';

      // 웹 버전
      final String webUrl = 'https://map.naver.com/p/directions/-/$latitude,$longitude,${Uri.encodeComponent(destination)}';

      if (await canLaunchUrl(Uri.parse(routeUrl))) {
        await launchUrl(Uri.parse(routeUrl), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('네이버 지도 실행 오류: $e');
    }
  }

  /// 자동차 경로 검색
  static Future<void> searchCarRoute({
    required String destination,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String routeUrl;
      if (latitude != null && longitude != null) {
        routeUrl = 'nmap://route/car?dlat=$latitude&dlng=$longitude&dname=${Uri.encodeComponent(destination)}&appname=com.yourapp.package';
      } else {
        // 좌표 없이 주소만으로 검색
        routeUrl = 'nmap://search?query=${Uri.encodeComponent(destination)}&appname=com.yourapp.package';
      }

      final String webUrl = 'https://map.naver.com/p/search/${Uri.encodeComponent(destination)}';

      if (await canLaunchUrl(Uri.parse(routeUrl))) {
        await launchUrl(Uri.parse(routeUrl), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('네이버 지도 실행 오류: $e');
    }
  }
}
