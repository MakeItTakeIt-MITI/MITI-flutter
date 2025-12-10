import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class QnaLabel extends StatelessWidget {
  final int num_of_answers;
  const QnaLabel({super.key, required this.num_of_answers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.r),
        color: MITIColor.gray600,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Text(
        num_of_answers == 0 ? '답변 대기중' : '답변 완료',
        style: MITITextStyle.xxxsmBold.copyWith(
            color: num_of_answers == 0
                ? MITIColor.gray100
                : V2MITIColor.primary5),
      ),
    );
  }
}
