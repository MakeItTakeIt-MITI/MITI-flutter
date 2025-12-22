import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';

class DailyModalManager {
  static const String _boxName = 'daily_modal_box';
  static const String _lastVisitKey = 'last_visit_date';
  static const String _dontShowTodayKey = 'dont_show_today';

  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static Box get box {
    if (_box == null) {
      throw Exception('DailyModalManager가 초기화되지 않았습니다. init()을 먼저 호출하세요.');
    }
    return _box!;
  }

  /// 오늘 날짜를 YYYY-MM-DD 형태로 반환
  static String get todayString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 마지막 방문 날짜 가져오기
  static String? getLastVisitDate() {
    return box.get(_lastVisitKey);
  }

  /// 마지막 방문 날짜 저장
  static Future<void> setLastVisitDate(String date) async {
    await box.put(_lastVisitKey, date);
    log('마지막 방문 날짜 저장: $date');
  }

  /// 오늘 다시 안보기 상태 확인
  static bool getDontShowToday() {
    final dontShowDate = box.get(_dontShowTodayKey);
    final result = dontShowDate == todayString;
    log('오늘 다시 안보기 상태: $result (저장된 날짜: $dontShowDate, 오늘: $todayString)');
    return result;
  }

  /// 오늘 다시 안보기 설정
  static Future<void> setDontShowToday() async {
    await box.put(_dontShowTodayKey, todayString);
    log('오늘 다시 안보기 설정: $todayString');
  }

  /// 모달을 보여야 하는지 확인 (메인 로직)
  static Future<bool> shouldShowModal() async {
    final lastVisit = getLastVisitDate();
    final today = todayString;

    log('=== 모달 표시 조건 확인 ===');
    log('마지막 방문: $lastVisit');
    log('오늘 날짜: $today');

    // 첫 방문이거나 지난 날 방문인 경우
    if (lastVisit == null || lastVisit != today) {
      log('첫 방문이거나 지난 날 방문 → 날짜 업데이트');
      await setLastVisitDate(today);

      // 오늘 다시 안보기 상태 확인
      final dontShow = getDontShowToday();
      if (!dontShow) {
        log('✅ 모달 표시');
        return true;
      } else {
        log('❌ 오늘 다시 안보기로 모달 숨김');
        return false;
      }
    } else {
      // 오늘 이미 방문한 경우
      log('오늘 이미 방문함');
      final dontShow = getDontShowToday();
      if (!dontShow) {
        log('✅ 모달 표시 (오늘 다시 안보기 안함)');
        return true;
      } else {
        log('❌ 오늘 다시 안보기로 모달 숨김');
        return false;
      }
    }
  }

  /// 디버그용: 모든 데이터 출력
  static void printDebugInfo() {
    log('=== DailyModal 디버그 정보 ===');
    log('마지막 방문: ${getLastVisitDate()}');
    log('오늘 다시 안보기: ${getDontShowToday()}');
    log('오늘 날짜: $todayString');
  }

  /// 테스트용: 모든 데이터 초기화
  static Future<void> resetAll() async {
    await box.clear();
    log('모든 데이터 초기화 완료');
  }
}
