import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/provider/widget/datetime_provider.dart';

class TimePicker extends StatelessWidget {
  final DateTimeType type;
  const TimePicker({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
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
                      '매치 시작 시간',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 14.sp,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ],
                ),
                Text(
                  '오후 3:00',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: const Color(0xFF4065F6),
                    fontSize: 14.sp,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.25,
                  ),
                )
              ],
            ),
          ),
          Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                    color: Colors.white,
                  ),
                  height: 130.h,
                  child: CupertinoDatePicker(
                    onDateTimeChanged: (DateTime dateTime) {
                      ref.read(timeProvider(type).notifier).update((state) => dateTime);
                      log('dateTime ${dateTime}');
                    },
                    mode: CupertinoDatePickerMode.time,
                  ),
                );
              },
          ),
          SizedBox(height: 56.h),
        ],
      ),
    );
  }
}