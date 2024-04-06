import 'package:intl/intl.dart';

class DateTimeUtil {
  static DateTime getyMd({required DateTime dateTime}) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static int getMonth({required String dateTime}) {
    return int.parse(DateFormat('MM').format(DateTime.parse(dateTime)));
  }

  static String getDateRange({required String start, required String end}) {
    final formatStart = DateFormat('MM월 dd일').format(DateTime.parse(start));
    final formatEnd = DateFormat('MM월 dd일').format(DateTime.parse(end));

    return '$formatStart ~ $formatEnd';
  }

  static String getDate({required DateTime dateTime}) {
    DateFormat dateFormat = DateFormat('yyyy / MM / dd');
    return dateFormat.format(dateTime);
  }

  static String getTime({required DateTime dateTime}) {
    DateFormat dateFormat = DateFormat('HH:mm');
    return dateFormat.format(dateTime);
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
    RegExp regex = RegExp(r'^[가-힣]{1,8}|[a-zA-Z]{1,14}\s[a-zA-Z]{1,14}$');
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
}
