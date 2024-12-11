import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';
import 'package:miti/theme/color_theme.dart';

class FaqSkeleton extends StatelessWidget {
  const FaqSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50.h),
        SizedBox(
          height: 16.h,
          child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) => const BoxSkeleton(width: 33, height: 16),
              separatorBuilder: (_, __) => SizedBox(width: 20.w),
              itemCount: 6),
        ),
        ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, __) => FaqCardSkeleton(),
            separatorBuilder: (_, __) => Container(),
            itemCount: 6)
      ],
    );
  }
}

class FaqCardSkeleton extends StatelessWidget {
  const FaqCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: MITIColor.gray600))),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BoxSkeleton(width: 286, height: 29),
            Icon(
              Icons.keyboard_arrow_down,
              color: MITIColor.gray400,
            )
          ],
        ),
      ),
    );
  }
}
