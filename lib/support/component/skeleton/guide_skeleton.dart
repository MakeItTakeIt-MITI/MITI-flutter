import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';

class GuideSkeleton extends StatelessWidget {
  const GuideSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        GuideChipSkeleton(),
        GuideImageSkeleton(),
        GuideInfoSkeleton(),
      ],
    );
  }
}

class GuideChipSkeleton extends StatelessWidget {
  const GuideChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 21.w, top: 12.h, bottom: 20.h),
      child: SizedBox(
        height: 38.h,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (_, __) => const BoxSkeleton(
                  width: 125,
                  height: 38,
                  borderRadius: 20,
                ),
            separatorBuilder: (_, __) => SizedBox(
                  width: 8.w,
                ),
            itemCount: 4),
      ),
    );
  }
}

class GuideImageSkeleton extends StatelessWidget {
  const GuideImageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BoxSkeleton(
          width: MediaQuery.of(context).size.width,
          height: 220,
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (idx) => Container(
                width: 4.r,
                height: 4.r,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: idx == 0 ? V2MITIColor.primary5 : MITIColor.gray400,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class GuideInfoSkeleton extends StatelessWidget {
  const GuideInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        children: [
          const BoxSkeleton(width: 330, height: 24),
          SizedBox(height: 28.h),
          ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (_, __) => const BoxSkeleton(
                    width: 330,
                    height: 21,
                  ),
              separatorBuilder: (_, __) => SizedBox(
                    height: 7.h,
                  ),
              itemCount: 5),
        ],
      ),
    );
  }
}
