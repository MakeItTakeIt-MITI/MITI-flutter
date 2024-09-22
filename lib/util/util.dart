import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// import 'package:timezone/browser.dart';

const String assetPathIcon = 'assets/images/v2/';

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

  static DateTime getyMd({required DateTime dateTime}) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String parseMd({required DateTime dateTime}) {
    DateFormat dateFormat = DateFormat('MM.dd');
    return dateFormat.format(dateTime);
  }

  static int getMonth({required String dateTime}) {
    return int.parse(DateFormat('MM').format(DateTime.parse(dateTime)));
  }

  static String getDateRange({required String start, required String end}) {
    final formatStart = DateFormat('MM월 dd일').format(DateTime.parse(start));
    final formatEnd = DateFormat('MM월 dd일').format(DateTime.parse(end));

    return '$formatStart ~ $formatEnd';
  }

  static String getDate({required DateTime dateTime, String sep = ' / '}) {
    DateFormat dateFormat = DateFormat('yyyy${sep}MM${sep}dd');
    return dateFormat.format(dateTime);
  }

  static String getDateTime({required DateTime dateTime}) {
    DateFormat dateFormat = DateFormat('MM.dd aa hh:mm', 'ko');
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
  static bool gameTitle(String input) {
    RegExp regex = RegExp(
        r'^[가-힣a-zA-Z\(\)\{\}\[\]0-9][가-힣a-zA-Z\(\)\{\}\[\]0-9\s\:]{4,64}$');
    return regex.hasMatch(input);
  }

  static bool gameDate(String input) {
    RegExp regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return regex.hasMatch(input);
  }

  static bool gameTime(String input) {
    RegExp regex = RegExp(r'^\d{2}:\d{2}$');
    return regex.hasMatch(input);
  }

  static bool gameAddress(String input) {
    RegExp regex = RegExp(r'^[가-힣a-zA-Z0-9][가-힣a-zA-Z0-9\s\-\(\)\.]{2,128}$');
    return regex.hasMatch(input);
  }

  static bool gameAddressDetail(String input) {
    RegExp regex = RegExp(r'^[가-힣a-zA-Z0-9][가-힣a-zA-Z0-9\s\-\(\)\.]{2,64}$');
    return regex.hasMatch(input);
  }

  static bool userName(String input) {
    RegExp regex = RegExp(r'^[가-힣]{1,8}$|^[a-zA-Z]{1,14}[a-zA-Z]{1,14}$');
    return regex.hasMatch(input);
  }

  static bool userNickname(String input) {
    RegExp regex = RegExp(r'^[가-힣a-zA-Z0-9]{3,15}$');
    return regex.hasMatch(input);
  }

  static bool userPassword(String input) {
    RegExp regex = RegExp(
        r'^(?=.*[\d])(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*()])[\w\d!@#$%^&*()]{8,20}$');
    return regex.hasMatch(input);
  }

  static bool userPhoneNumber(String input) {
    RegExp regex = RegExp(r'^01(\d){9}$');
    return regex.hasMatch(input);
  }

  static bool accountNumber(String input) {
    RegExp regex = RegExp(r'\d{10,15}$');
    return regex.hasMatch(input);
  }

  static bool courtName(String input) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9가-힣\s\-.()]{2,32}$');
    return regex.hasMatch(input);
  }

  static bool validForm(String min_invitation, String max_invitation) {
    if (min_invitation.isNotEmpty && max_invitation.isNotEmpty) {
      if (int.parse(min_invitation) >= int.parse(max_invitation)) {
        return false;
      } else if (int.parse(max_invitation) <= 0) {
        return false;
      }
    }
    return true;
  }
}

class TextStyleUtil {
  static TextStyle getLabelTextStyle() {
    return TextStyle(
      color: const Color(0xFF999999),
      fontSize: 14.sp,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: -0.25.sp,
    );
  }

  static TextStyle getTextStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 14.sp,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      letterSpacing: -0.25.sp,
    );
  }

  static TextStyle getHintTextStyle() {
    return TextStyle(
      color: const Color(0xFF969696),
      fontSize: 14.sp,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25.sp,
    );
  }
}
