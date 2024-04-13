import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../util/provider/date_provider.dart';
import '../../util/util.dart';
import '../provider/widget/datetime_provider.dart';

class CustomCalendar extends ConsumerStatefulWidget {
  final RangeSelectionMode? rangeSelectionMode;

  const CustomCalendar({
    super.key,
    this.rangeSelectionMode,
  });

  @override
  ConsumerState<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends ConsumerState<CustomCalendar> {
  late DateTime selectedDay;
  DateTime focusedDay = DateTime.now();
  DateTime? rangeStartDay;
  DateTime? rangeEndDay;

  DateTime getOnlyYMd(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  bool isRangeDate(String startDate, String endDate, DateTime validDay) {
    return getOnlyYMd(DateTime.parse(startDate)).isBefore(validDay) &&
            getOnlyYMd(DateTime.parse(endDate)).isAfter(validDay) ||
        getOnlyYMd(DateTime.parse(startDate)).isAtSameMomentAs(validDay) ||
        getOnlyYMd(DateTime.parse(endDate)).isAtSameMomentAs(validDay);
  }

  bool validRangeDate() {
    if (rangeStartDay != null && rangeEndDay != null) {
      if (isSameDate(rangeStartDay!) && rangeEndDay!.isAfter(DateTime.now())) {
        return true;
      } else if (rangeStartDay!.isBefore(DateTime.now()) &&
          rangeEndDay!.isBefore(DateTime.now())) {
        return false;
      } else if (rangeStartDay!.isBefore(DateTime.now()) &&
          rangeEndDay!.isAfter(DateTime.now())) {
        return false;
      }
    }
    return true;
  }

  bool validRangeStartDay() {
    // return ref.read(gameFormProvider.notifier).validDatetime();
    if(rangeStartDay != null){
      if (rangeStartDay!.isBefore(DateTime.now())){
        return false;
      }
    }return true;
  }

  bool validToday() {
    if (rangeStartDay != null && rangeEndDay != null) {
      if (isSameDate(rangeStartDay!) && rangeEndDay!.isAfter(DateTime.now())) {
        return true;
      } else if (rangeStartDay!.isBefore(DateTime.now()) &&
          rangeEndDay!.isBefore(DateTime.now())) {
        if (isSameDate(rangeEndDay!)) {
          return false;
        } else {
          return true;
        }
      } else if (rangeStartDay!.isBefore(DateTime.now()) &&
          rangeEndDay!.isAfter(DateTime.now())) {
        return false;
      }
    }
    return true;
  }

  bool isSameDate(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.compareTo(DateTime(now.year, now.month, now.day)) == 0;
  }

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now();
  }

  HeaderStyle getHeaderStyle() {
    final format = DateFormat('y년 M월');
    final titleTextStyle = TextStyle(
      fontSize: 16.sp,
      letterSpacing: -0.25.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF454545),
    );
    return HeaderStyle(
      headerPadding: EdgeInsets.zero,
      titleTextFormatter: (date, locale) => format.format(date),
      // leftChevronPadding: EdgeInsets.only(left: 50.w, top: 28.h),
      leftChevronMargin: EdgeInsets.only(left: 50.w),
      // rightChevronPadding:EdgeInsets.only(right: 50.w),
      rightChevronMargin: EdgeInsets.only(right: 50.w),
      titleCentered: true,
      formatButtonVisible: false,
      titleTextStyle: titleTextStyle,
    );
  }

  CalendarStyle getCalendarStyle() {
    final textStyle = TextStyle(
      fontSize: 14.sp,
      letterSpacing: -0.25.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF333333),
    );
    final BoxDecoration boxDecoration = BoxDecoration(
      color: const Color(0xFF4065F6),
      borderRadius: BorderRadius.circular(8.r),
    );

    return CalendarStyle(
      cellMargin: EdgeInsets.symmetric(
        vertical: 4.h,
      ),
      todayTextStyle: textStyle.copyWith(color: Colors.white),
      weekendTextStyle: textStyle,
      outsideTextStyle: textStyle.copyWith(color: const Color(0xFF969696)),
      defaultTextStyle: textStyle,
      withinRangeDecoration: validRangeDate()
          ? const BoxDecoration(color: Color(0xFF4065F6))
          : const BoxDecoration(color: Color(0xFFFC0000)),
      selectedDecoration: boxDecoration,
      rangeEndTextStyle: textStyle.copyWith(color: Colors.white),
      rangeStartTextStyle: textStyle.copyWith(color: Colors.white),
      withinRangeTextStyle: textStyle.copyWith(color: Colors.white),
      todayDecoration: boxDecoration.copyWith(
          color:
              validToday() ? const Color(0xFF4065F6) : const Color(0xFFFC0000),
          borderRadius: validToday() ? null : BorderRadius.zero),
      // isTodayHighlighted: false,
      rangeHighlightScale: 1.0,
      rangeHighlightColor: const Color(0xFF4065F6),
      rangeStartDecoration: rangeEndDay != null
          ? boxDecoration.copyWith(
              color: validRangeDate()
                  ? const Color(0xFF4065F6)
                  : const Color(0xFFFC0000),
              borderRadius: BorderRadiusDirectional.horizontal(
                  start: Radius.circular(8.r)))
          : boxDecoration.copyWith(
              color: validRangeStartDay()
                  ? const Color(0xFF4065F6)
                  : const Color(0xFFFC0000)),
      rangeEndDecoration: boxDecoration.copyWith(
          color: validRangeDate()
              ? const Color(0xFF4065F6)
              : const Color(0xFFFC0000),
          borderRadius:
              BorderRadiusDirectional.horizontal(end: Radius.circular(8.r))),
      weekendDecoration: boxDecoration.copyWith(color: Colors.transparent),
      defaultDecoration: boxDecoration.copyWith(color: Colors.transparent),
      outsideDecoration: boxDecoration.copyWith(color: Colors.transparent),
      tablePadding: EdgeInsets.only(left: 12.r, right: 12.r, bottom: 12.r),
    );
  }

  DaysOfWeekStyle getDaysOfWeekStyle() {
    final textStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF333333),
    );
    return DaysOfWeekStyle(
      dowTextFormatter: (date, locale) => DateFormat.E('ko').format(date)[0],
      weekendStyle: textStyle,
      weekdayStyle: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.close,
                  ))),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return TableCalendar(
                // locale: 'ko_KR',
                pageJumpingEnabled: true,
                currentDay: selectedDay,
                focusedDay: selectedDay,
                rangeEndDay: rangeEndDay,
                rangeStartDay: rangeStartDay,
                daysOfWeekHeight: 44.h,
                rowHeight: 44.h,
                onRangeSelected: (start, end, focusedDay) {
                  log('start $start');
                  log('end $end');
                  log('focusedDay $focusedDay');
                  rangeStartDay = start;
                  rangeEndDay = end;
                  selectedDay = start!;
                  final startDate = ref.read(dateProvider(DateTimeType.start));
                  final endDate = ref.read(dateProvider(DateTimeType.end));
                  if (end == null) {
                    /// 날짜 하나만 선택인 경우
                    /// 시작, 종료 날짜를 동일 날짜로 변경
                    final newStartDate = DateTimeUtil.copyWithyMd(
                        newDateTime: start, baseDateTime: startDate);
                    final newEndDate = DateTimeUtil.copyWithyMd(
                        newDateTime: start, baseDateTime: endDate);
                    ref
                        .read(dateProvider(DateTimeType.start).notifier)
                        .update((state) => newStartDate);
                    ref
                        .read(dateProvider(DateTimeType.end).notifier)
                        .update((state) => newEndDate);
                  } else {
                    final newStartDate = DateTimeUtil.copyWithyMd(
                        newDateTime: start, baseDateTime: startDate);
                    final newEndDate = DateTimeUtil.copyWithyMd(
                        newDateTime: end, baseDateTime: endDate);
                    ref
                        .read(dateProvider(DateTimeType.start).notifier)
                        .update((state) => newStartDate);
                    ref
                        .read(dateProvider(DateTimeType.end).notifier)
                        .update((state) => newEndDate);
                  }

                  setState(() {});
                },
                rangeSelectionMode: widget.rangeSelectionMode == null
                    ? RangeSelectionMode.toggledOff
                    : RangeSelectionMode.toggledOn,
                onDaySelected: (DateTime selected, DateTime focusedDay) {
                  ref
                      .read(dateProvider(DateTimeType.start).notifier)
                      .update((state) => selected);
                  setState(() {
                    selectedDay = selected;
                    this.focusedDay = focusedDay;
                  });
                },
                // selectedDayPredicate: (day) {
                //   return isSameDay(selectedDay, day);
                // },
                firstDay: DateTime(1900, 1, 1),
                lastDay: DateTime(2999, 12, 31),
                headerStyle: getHeaderStyle(),
                daysOfWeekStyle: getDaysOfWeekStyle(),
                calendarStyle: getCalendarStyle(),
              );
            },
          ),
        ],
      ),
    );
  }
}
