import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';
import 'package:miti/theme/color_theme.dart';

class SupportDetailSkeleton extends StatelessWidget {
  const SupportDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 53, height: 18),
          SizedBox(height: 20.h),
          const BoxSkeleton(width: 330, height: 18),
          SizedBox(height: 8.h),
          const BoxSkeleton(width: 92, height: 12),
          SizedBox(height: 20.h),
          ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, __) => const BoxSkeleton(width: 330, height: 21),
              separatorBuilder: (_, __) => SizedBox(height: 7.h),
              itemCount: 4),
          SizedBox(height: 20.h),
          ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, __) => const SupportResponseCardSkeleton(),
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemCount: 2),
        ],
      ),
    );
  }
}

class SupportResponseCardSkeleton extends StatelessWidget {
  const SupportResponseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: MITIColor.gray700,
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 92, height: 12),
          SizedBox(height: 10.h),
          ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, __) => const BoxSkeleton(width: 330, height: 21),
              separatorBuilder: (_, __) => SizedBox(height: 7.h),
              itemCount: 4),
        ],
      ),
    );
  }
}
