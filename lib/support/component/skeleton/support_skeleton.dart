import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';

class SupportCardListSkeleton extends StatelessWidget {
  const SupportCardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SupportSkeleton(),
      SizedBox(height: 12.h),
      const SupportSkeleton(),
      SizedBox(height: 12.h),
      const SupportSkeleton(),
    ],);
  }
}

class SupportSkeleton extends StatelessWidget {
  const SupportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: MITIColor.gray700,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 290, height: 14),
          SizedBox(height: 8.h),
          const BoxSkeleton(width: 92, height: 12),
          SizedBox(height: 16.h),
          const BoxSkeleton(width: 62, height: 18),
        ],
      ),
    );
  }
}
