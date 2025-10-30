
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/provider/widget/datetime_provider.dart';

import '../../../util/util.dart';

class TimePicker extends ConsumerWidget {
  final DateTimeType type;

  const TimePicker({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = type == DateTimeType.start ? '시작' : '종료';
    final showTimePicker = ref.watch(showTimePickerProvider(type));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: InkWell(
              onTap: () {
                ref
                    .read(showTimePickerProvider(type).notifier)
                    .update((state) => !state);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon/clock.svg',
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '매치 $title 시간',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 14.sp,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.25.sp,
                        ),
                      ),
                    ],
                  ),
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      DateTime dateTime =
                          ref.watch(dateProvider(type)) ?? DateTime.now();
                      bool after = false;
                      if (dateTime.hour > 12) {
                        after = true;
                        dateTime = dateTime.subtract(const Duration(hours: 12));
                      } else if (dateTime.hour == 12) {
                        after = true;
                      }
                      final dateFormat = DateFormat.Hm('ko');
                      final String noon = after ? '오후' : '오전';
                      final time = dateFormat.format(dateTime);
                      return Text(
                        '$noon $time',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: const Color(0xFF4065F6),
                          fontSize: 14.sp,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.25.sp,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          if (showTimePicker)
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                // final minimumDate = ref.read(timeProvider(DateTimeType.start));
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                    color: Colors.white,
                  ),
                  height: 100.h,
                  child: CupertinoDatePicker(
                    // minimumDate: minimumDate,
                    onDateTimeChanged: (DateTime dateTime) {
                      final time = ref.read(dateProvider(type));
                      DateTime newTime;
                      if (time == null) {
                        newTime = DateTimeUtil.copyWithHm(
                            newDateTime: dateTime,
                            baseDateTime: DateTime.now());
                      } else {
                        newTime = DateTimeUtil.copyWithHm(
                            newDateTime: dateTime, baseDateTime: time);
                      }
                      ref
                          .read(dateProvider(type).notifier)
                          .update((state) => newTime);
                    },
                    mode: CupertinoDatePickerMode.time,
                  ),
                );
              },
            ),
          // SizedBox(height: 56.h),
        ],
      ),
    );
  }
}
