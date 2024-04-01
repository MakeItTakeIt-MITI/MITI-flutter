import 'package:intl/intl.dart';

class DateTimeUtil {
  static DateTime getyMd({required DateTime dateTime}) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  static int getMonth({required String dateTime}){
    return int.parse(DateFormat('MM').format(DateTime.parse(dateTime)));
  }

  static String getDateRange({required String start, required String end}){
    final formatStart = DateFormat('MM월 dd일').format(DateTime.parse(start));
    final formatEnd = DateFormat('MM월 dd일').format(DateTime.parse(end));

    return '$formatStart ~ $formatEnd';
  }

  static String getDate({required DateTime dateTime}){
    DateFormat dateFormat = DateFormat('yyyy / MM / dd');
    return dateFormat.format(dateTime);
  }

}
