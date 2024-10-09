import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';

class UserInfoSkeleton extends StatelessWidget {
  const UserInfoSkeleton({super.key});

  Row getInfo({required String title, required double width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.mdLight.copyWith(
            color: MITIColor.gray300,
          ),
        ),
        BoxSkeleton(width: width, height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MITIColor.gray800,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        children: [
          getInfo(title: '이름', width: 41),
          SizedBox(height: 12.h),
          getInfo(title: '생년월일', width: 73),
          SizedBox(height: 12.h),
          getInfo(title: '휴대폰 번호', width: 101),
          SizedBox(height: 12.h),
          getInfo(title: '로그인 방식', width: 51)
        ],
      ),
    );
  }
}
