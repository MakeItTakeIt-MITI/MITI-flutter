import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

class ChatDateComponent extends StatelessWidget {
  final String date;

  const ChatDateComponent({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 20.h),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: MITIColor.gray750,
        ),
        alignment: Alignment.center,
        child: Text(
          date,
          style: MITITextStyle.mdSemiBold.copyWith(
            color: MITIColor.gray300,
          ),
        ),
      ),
    );
  }
}
