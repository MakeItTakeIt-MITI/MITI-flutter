// // 1. 버전 체크 서비스
// import 'dart:io';
//
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/foundation.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../common/model/remote_config_model.dart';
//
// class VersionCheckService {
//   // 서버에서 최소 요구 버전을 가져옴 (API 호출)
//   Future<String> getMinRequiredVersion() async {
//     // 실제 구현에서는 API 호출
//     // 예: final response = await http.get(Uri.parse('your-api-url/app-version'));
//     // 예시로 하드코딩된 버전
//     return '1.5.0'; // 서버에서 반환하는 최소 요구 버전
//   }
//
//   // Future<void> _initialize() async {
//   //   try {
//   //     final _remoteConfig = FirebaseRemoteConfig.instance;
//   //     // 디버그 모드에서는 캐시 간격을 짧게 설정하여 빠른 테스트 가능
//   //     await _remoteConfig.setConfigSettings(RemoteConfigSettings(
//   //       fetchTimeout: const Duration(minutes: 1),
//   //       minimumFetchInterval: kDebugMode
//   //           ? const Duration(minutes: 1) // 개발 중에는 1분
//   //           : const Duration(hours: 1), // 배포 시에는 1시간
//   //     ));
//   //
//   //     // 기본값 설정 (Firebase 연결 실패 시 사용)
//   //     await _remoteConfig.setDefaults({
//   //       RemoteConfigKeys.minAppVersion: '1.1.0',
//   //       RemoteConfigKeys.recommendedAppVersion: '1.1.0',
//   //       RemoteConfigKeys.forceUpdateMessage: '앱 업데이트가 필요합니다.',
//   //       RemoteConfigKeys.appStoreUrl: '',
//   //       RemoteConfigKeys.playStoreUrl: '',
//   //     });
//   //
//   //     // 먼저 초기화 완료 상태로 표시 (기본값 사용)
//   //     state = state.copyWith(initialized: true);
//   //
//   //     // 그 후 백그라운드에서 fetch 시도 (UI는 계속 표시됨)
//   //     try {
//   //       bool updated = await _remoteConfig.fetchAndActivate();
//   //       debugPrint('Remote config fetched and activated: $updated');
//   //
//   //       // if (updated) {
//   //       // 업데이트된 원격 구성으로 앱 버전 확인
//   //       await _checkAppVersion();
//   //       // }
//   //     } catch (e) {
//   //       debugPrint('Remote config fetch error (non-blocking): $e');
//   //     }
//   //
//   //     // 주기적으로 Remote Config 업데이트 (앱이 계속 실행 중일 때)
//   //     _setupPeriodicFetch();
//   //   } catch (e) {
//   //     debugPrint('Remote config initialization error: $e');
//   //     // 오류가 발생해도 초기화 표시 (기본값 사용)
//   //     state = state.copyWith(initialized: true);
//   //   }
//   // }
//
//   // 현재 앱 버전 가져오기
//   Future<String> getCurrentVersion() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     return packageInfo.version;
//   }
//
//   // 버전 비교
//   bool isUpdateRequired(String currentVersion, String minRequiredVersion) {
//     List<int> current = currentVersion.split('.').map(int.parse).toList();
//     List<int> required = minRequiredVersion.split('.').map(int.parse).toList();
//
//     for (int i = 0; i < 3; i++) {
//       if (current[i] < required[i]) {
//         return true;
//       } else if (current[i] > required[i]) {
//         return false;
//       }
//     }
//     return false;
//   }
//
//   // 스토어 URL 실행
//
// }
