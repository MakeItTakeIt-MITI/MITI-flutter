import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:timezone/browser.dart';

const String assetPathIcon = 'assets/images/v2/';

enum BuildEnvironment {
  development,
  production,
}

class EnvUtil {
  // Private constructor
  EnvUtil._();

  // Singleton instance
  static final EnvUtil _instance = EnvUtil._();

  // Getter for the instance
  static EnvUtil get instance => _instance;

  // Current environment
  BuildEnvironment _environment = BuildEnvironment.development;

  // Getter for current environment
  BuildEnvironment get env => _environment;

  // Method to initialize/set the environment
  void initialize({required BuildEnvironment environment}) {
    _environment = environment;
    debugPrint('Environment initialized: $_environment');
  }

  // Helper methods
  bool get isDevelopment => _environment == BuildEnvironment.development;

  bool get isProduction => _environment == BuildEnvironment.production;
}

enum AssetType {
  logo,
  icon,
  gif;
}

class AssetUtil {
  static String getAssetPath(
      {required AssetType type,
      required String name,
      String extension = 'svg'}) {
    return '$assetPathIcon${type.name}/$name.$extension';
  }
}

class DateTimeUtil {
  // // 기본 타임존을 Asia/Seoul로 지정
  // static String timezone = 'Asia/Seoul';
  //
  // // 현지 시간을 한국시간으로 변환할때 사용
  // static final korTimeZone = getLocation('Asia/Seoul');

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return "방금 전";
    }

    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (seconds < 60) {
      return "방금 전";
    } else if (minutes < 60) {
      return "${minutes}분 전";
    } else if (hours < 24) {
      return "${hours}시간 전";
    } else if (days < 30) {
      return "${days}일 전";
    } else {
      // 정확한 월/년 계산
      int yearDiff = now.year - dateTime.year;
      int monthDiff = now.month - dateTime.month;

      // 월이 음수인 경우 연도에서 빌려오기
      if (monthDiff < 0) {
        yearDiff--;
        monthDiff += 12;
      }

      // 일까지 고려한 보정
      if (now.day < dateTime.day) {
        monthDiff--;
        if (monthDiff < 0) {
          yearDiff--;
          monthDiff += 12;
        }
      }

      if (yearDiff > 0) {
        return "${yearDiff}년 전";
      } else if (monthDiff > 0) {
        return "${monthDiff}개월 전";
      } else {
        return "${days}일 전";
      }
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isSameTime(DateTime date1, DateTime date2) {
    return date1.hour == date2.hour && date1.minute == date2.minute;
  }

  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('a hh:mm', "ko");
    return formatter.format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat("MM월 dd일 HH:mm");
    return formatter.format(dateTime);
  }

  static String formatStringDateTime(String dateTime) {
    return DateFormat('yyyy년 MM월 dd일 HH:mm', 'ko')
        .format(DateTime.parse(dateTime).toLocal());
  }

  static String formatDateTimeToString(DateTime dateTime) {
    return DateFormat('yyyy 년 MM 월 dd 일 HH:mm', 'ko').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    final formatter = DateFormat("MM월 dd일");
    return formatter.format(dateTime);
  }

  static String parseMd({required DateTime dateTime}) {
    DateFormat dateFormat = DateFormat('MM.dd');
    return dateFormat.format(dateTime);
  }

  // /// ChatModel의 date("01월 01일"), time("오후 01:01") 문자열을 DateTime으로 변환
  static DateTime parseDateTime(String date, String time) {
    try {
      // date 파싱: "01월 01일" -> 월, 일 추출
      final dateRegex = RegExp(r'(\d{1,2})월\s(\d{1,2})일');
      final dateMatch = dateRegex.firstMatch(date);

      if (dateMatch == null) {
        throw FormatException('날짜 포맷이 올바르지 않습니다: $date');
      }

      final month = int.parse(dateMatch.group(1)!);
      final day = int.parse(dateMatch.group(2)!);

      // time 파싱: "오후 01:01" -> 시간, 분 추출
      final timeRegex = RegExp(r'(오전|오후)\s(\d{1,2}):(\d{2})');
      final timeMatch = timeRegex.firstMatch(time);

      if (timeMatch == null) {
        throw FormatException('시간 포맷이 올바르지 않습니다: $time');
      }

      final period = timeMatch.group(1)!;
      final hour = int.parse(timeMatch.group(2)!);
      final minute = int.parse(timeMatch.group(3)!);

      // 24시간 형식으로 변환
      final actualHour = _convertTo24Hour(period, hour);

      // 년도 추정 (현재 년도 기준)
      final year = _estimateYear(month, day);

      return DateTime(year, month, day, actualHour, minute);
    } catch (e) {
      print('DateTime 파싱 오류: $e');
      print('입력 값 - date: "$date", time: "$time"');

      // 파싱 실패 시 현재 시간 반환
      return DateTime.now();
    }
  }

  /// 월, 일 정보로 년도 추정
  static int _estimateYear(int month, int day) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentDay = now.day;

    // 현재 날짜와 비교해서 년도 추정
    final candidateDate = DateTime(currentYear, month, day);
    final currentDate = DateTime(currentYear, currentMonth, currentDay);

    // 후보 날짜가 현재보다 너무 미래라면 (6개월 이상) 작년으로 추정
    final daysDifference = candidateDate.difference(currentDate).inDays;

    if (daysDifference > 180) {
      return currentYear - 1;
    } else if (daysDifference < -180) {
      // 너무 과거라면 내년으로 추정
      return currentYear + 1;
    } else {
      return currentYear;
    }
  }

  /// 오전/오후를 24시간 형식으로 변환
  static int _convertTo24Hour(String period, int hour) {
    if (period == '오전') {
      return hour == 12 ? 0 : hour;
    } else {
      // 오후
      return hour == 12 ? 12 : hour + 12;
    }
  }

  static String getDate({required DateTime dateTime, String sep = ' / '}) {
    DateFormat dateFormat = DateFormat('yyyy${sep}MM${sep}dd');
    return dateFormat.format(dateTime);
  }

  static DateTime copyWithyMd(
      {required DateTime newDateTime, required DateTime? baseDateTime}) {
    if (baseDateTime == null) {
      return DateTime.now().copyWith(
          year: newDateTime.year,
          month: newDateTime.month,
          day: newDateTime.day);
    }
    return baseDateTime.copyWith(
        year: newDateTime.year, month: newDateTime.month, day: newDateTime.day);
  }

  static DateTime copyWithHm(
      {required DateTime newDateTime, required DateTime baseDateTime}) {
    return baseDateTime.copyWith(
        hour: newDateTime.hour, minute: newDateTime.minute);
  }
}

class NumberUtil {
  static String format(String input) {
    RegExp regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return input.replaceAllMapped(regex, (Match match) => '${match[1]},');
  }
}

class ValidRegExp {
  static bool gameAddress(String input) {
    RegExp regex = RegExp(r'^[가-힣a-zA-Z0-9][가-힣a-zA-Z0-9\s\-\(\)\.]{2,128}$');
    return regex.hasMatch(input);
  }

  static bool userName(String input) {
    RegExp regex = RegExp(r'^[가-힣]{1,8}$|^[a-zA-Z]{1,14}[a-zA-Z]{1,14}$');
    return regex.hasMatch(input);
  }

  static bool userNickname(String input) {
    RegExp regex = RegExp(r'^[가-힣a-zA-Z0-9]{2,15}$');
    return regex.hasMatch(input);
  }

  static bool userPassword(String input) {
    RegExp regex = RegExp(
        r'^(?=.*[\d])(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*()])[\w\d!@#$%^&*()]{8,20}$');
    return regex.hasMatch(input);
  }

  static bool accountNumber(String input) {
    RegExp regex = RegExp(r'\d{10,15}$');
    return regex.hasMatch(input);
  }

  static bool courtName(String input) {
    return input.isNotEmpty && input.length < 30;
  }

  // 최소인원이 최대인원보다 큰지 확인
  static bool validForm(String min_invitation, String max_invitation) {
    if (min_invitation.isNotEmpty && max_invitation.isNotEmpty) {
      if (int.parse(min_invitation) > int.parse(max_invitation)) {
        return false;
      }
    }
    return true;
  }
}

void focusScrollable(int i, List<GlobalKey> formKeys) {
  log("scrollalble ${i}");
  Scrollable.ensureVisible(
    formKeys[i].currentContext!,
    duration: const Duration(milliseconds: 600),
    alignment: 0.5,
    curve: Curves.easeInOut,
  );
}
