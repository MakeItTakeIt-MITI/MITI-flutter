import 'dart:developer';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/remote_config_model.dart';

part 'update_provider.g.dart';

@Riverpod(keepAlive: true)
class Update extends _$Update {
  final _remoteConfig = FirebaseRemoteConfig.instance;

  @override
  RemoteConfigState build() {
    _initialize();
    return RemoteConfigState();
  }

  Future<void> _initialize() async {
    log("update initialize");
    try {
      // 디버그 모드에서는 캐시 간격을 짧게 설정하여 빠른 테스트 가능
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode
            ? const Duration(seconds: 3) // 개발 중에는 1분
            : const Duration(hours: 12), // 배포 시에는 1시간
      ));

      // 기본값 설정 (Firebase 연결 실패 시 사용)
      /// todo 버전 변경 될 때마다 변경
      await _remoteConfig.setDefaults({
        RemoteConfigKeys.recommendedAppVersion: '1.2.2',
        RemoteConfigKeys.minimumAppVersion: '1.2.2',
        RemoteConfigKeys.recommendUpdateMessage: '앱 업데이트가 필요합니다.',
        RemoteConfigKeys.appStoreUrl:
            'https://apps.apple.com/us/app/miti/id6503062372',
        RemoteConfigKeys.playStoreUrl:
            'https://play.google.com/store/apps/details?id=com.miti.miti&hl=ko&pli=1',
      });

      // 먼저 초기화 완료 상태로 표시 (기본값 사용)
      // state = state.copyWith(initialized: true);
      // 그 후 백그라운드에서 fetch 시도 (UI는 계속 표시됨)
      try {
        bool updated = await _remoteConfig.fetchAndActivate();
        debugPrint('Remote config fetched and activated: $updated');

        checkAppVersion();
      } catch (e) {
        debugPrint('Remote config fetch error (non-blocking): $e');
      }

      // 주기적으로 Remote Config 업데이트 (앱이 계속 실행 중일 때)
      // _setupPeriodicFetch();
    } catch (e) {
      debugPrint('Remote config initialization error: $e');
      // 오류가 발생해도 초기화 표시 (기본값 사용)
      // state = state.copyWith(initialized: true);
    }
  }

  Future<void> checkAppVersion() async {
    try {
      // 앱 현재 버전 정보 가져오기
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      // log("currentVersion = $currentVersion");
      // print("currentVersion = $currentVersion");

      // Remote Config에서 최소 버전과 권장 버전 가져오기

      final prefixPlatform =
          Platform.isIOS ? RemoteConfigKeys.ios : RemoteConfigKeys.aos;
      final minimumAppVersion = _remoteConfig
          .getString(prefixPlatform + RemoteConfigKeys.minimumAppVersion);
      final recommendedAppVersion = _remoteConfig
          .getString(prefixPlatform + RemoteConfigKeys.recommendedAppVersion);
      final recommendUpdateMessage = _remoteConfig
          .getString(prefixPlatform + RemoteConfigKeys.recommendUpdateMessage);
      final minimumUpdateMessage = _remoteConfig
          .getString(prefixPlatform + RemoteConfigKeys.minimumUpdateMessage);

      // 스토어 URL 가져오기
      final appStoreUrl = _remoteConfig.getString(RemoteConfigKeys.appStoreUrl);
      final playStoreUrl =
          _remoteConfig.getString(RemoteConfigKeys.playStoreUrl);

      // 플랫폼에 맞는 스토어 URL 설정
      final storeUrl = Platform.isIOS ? appStoreUrl : playStoreUrl;

      // 버전 비교
      final needForceUpdate = isVersionLower(currentVersion, minimumAppVersion);
      final needRecommendedUpdate =
          isVersionLower(currentVersion, recommendedAppVersion);
      final needRecommendUpdate =
          isVersionLower(minimumAppVersion, recommendedAppVersion);

      if (needForceUpdate && needRecommendedUpdate && needRecommendUpdate) {
        state = state.copyWith(
          forceUpdate: needForceUpdate,
          recommendedUpdate: false,
          currentAppVersion: currentVersion,
          updateMessage: _generateUpdateMessage(recommendUpdateMessage),
          updateVersion: recommendedAppVersion,
          storeUrl: storeUrl,
        );
      } else if (needForceUpdate) {
        state = state.copyWith(
          forceUpdate: needForceUpdate,
          recommendedUpdate: false,
          currentAppVersion: currentVersion,
          updateMessage: _generateUpdateMessage(minimumUpdateMessage),
          updateVersion: minimumAppVersion,
          storeUrl: storeUrl,
        );
      } else if (needRecommendedUpdate) {
        state = state.copyWith(
          forceUpdate: false,
          recommendedUpdate: needRecommendedUpdate,
          currentAppVersion: currentVersion,
          updateMessage: _generateUpdateMessage(recommendUpdateMessage),
          updateVersion: recommendedAppVersion,
          storeUrl: storeUrl,
        );
      }

      // log("minimumAppVersion = ${minimumAppVersion}");
      // log("recommendedAppVersion = ${recommendedAppVersion}");
      // log("state forceUpdate = ${state.forceUpdate}");
      // log("state recommendedUpdate = ${state.recommendedUpdate}");
      // log("state currentAppVersion= ${state.currentAppVersion}");
      // log("state updateVersion= ${state.updateVersion}");
      // log("state updateMessage= ${state.updateMessage}");
      // log("state storeUrl = ${state.storeUrl}");
      //
      // print("minimumAppVersion = ${minimumAppVersion}");
      // print("recommendedAppVersion = ${recommendedAppVersion}");
      // print("state forceUpdate = ${state.forceUpdate}");
      // print("state recommendedUpdate = ${state.recommendedUpdate}");
      // print("state currentAppVersion= ${state.currentAppVersion}");
      // print("state updateVersion= ${state.updateVersion}");
      // print("state updateMessage= ${state.updateMessage}");
      // print("state storeUrl = ${state.storeUrl}");
    } catch (e) {
      debugPrint('App version check error: $e');
    }
  }

  // 버전 비교 로직 (semver 형식 사용: x.y.z)
  bool isVersionLower(String currentVersion, String targetVersion) {
    if (targetVersion.isEmpty) return false;

    final currentParts = currentVersion.split('.');
    final targetParts = targetVersion.split('.');

    // 버전 비교 로직
    for (int i = 0; i < targetParts.length; i++) {
      // 현재 버전이 더 짧으면 하위 버전으로 간주
      if (i >= currentParts.length) return true;

      final currentPart = int.tryParse(currentParts[i]) ?? 0;
      final targetPart = int.tryParse(targetParts[i]) ?? 0;

      if (currentPart < targetPart) return true;
      if (currentPart > targetPart) return false;
    }

    return false; // 동일한 버전이거나 현재 버전이 더 높음
  }

  List<String> _generateUpdateMessage(String updateMessage) {
    return updateMessage.split('@');
  }
}
