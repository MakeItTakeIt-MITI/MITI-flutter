import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../util/provider/date_provider.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now();
  }

  HeaderStyle getHeaderStyle() {
    final format = DateFormat('y년 M월');
    final titleTextStyle = TextStyle(
      fontSize: 16.sp,
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
      todayDecoration: boxDecoration,
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
      dowTextFormatter: (date, locale) => DateFormat.E('en').format(date)[0],
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
                daysOfWeekHeight: 44.h,
                rowHeight: 44.h,
                onDaySelected: (DateTime selected, DateTime focusedDay) {
                  ref.read(dateProvider.notifier).update((state) => selected);
                  setState(() {
                    selectedDay = selected;
                  });
                },
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
