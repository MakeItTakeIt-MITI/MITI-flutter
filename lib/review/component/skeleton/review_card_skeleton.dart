import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import '../../../util/util.dart';

class ReviewCardListSkeleton extends StatelessWidget {
  const ReviewCardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ReviewCardSkeleton(hasComment: true),
        SizedBox(height: 8.h),
        const ReviewCardSkeleton(hasComment: false),
        SizedBox(height: 8.h),
        const ReviewCardSkeleton(hasComment: true),
        SizedBox(height: 8.h),
        const ReviewCardSkeleton(hasComment: false),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class ReviewCardSkeleton extends StatelessWidget {
  final bool hasComment;

  const ReviewCardSkeleton({super.key, required this.hasComment});

  @override
  Widget build(BuildContext context) {
    final startList = List.generate(
      5,
      (_) => CustomSkeleton(
        skeleton: SvgPicture.asset(
          AssetUtil.getAssetPath(type: AssetType.icon, name: 'skeleton_star'),
          width: 16.r,
          height: 16.r,
        ),
      ),
    ).toList();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 21.w,
        vertical: 24.h,
      ),
      color: MITIColor.gray750,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const BoxSkeleton(width: 98, height: 18),
                    SizedBox(width: 8.w),
                    const BoxSkeleton(width: 42, height: 18, borderRadius: 100),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Text(
                      '평점',
                      style:
                          MITITextStyle.xxsm.copyWith(color: MITIColor.gray100),
                    ),
                    SizedBox(width: 32.h),
                    ...startList,
                    SizedBox(width: 6.h),
                    const BoxSkeleton(width: 42, height: 18),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      '좋았던 점',
                      style:
                          MITITextStyle.xxsm.copyWith(color: MITIColor.gray100),
                    ),
                    SizedBox(width: 16.h),
                    const BoxSkeleton(width: 79, height: 34, borderRadius: 100),
                    SizedBox(width: 8.h),
                    const BoxSkeleton(width: 79, height: 34, borderRadius: 100),
                  ],
                ),
                if (hasComment) SizedBox(height: 12.h),
                if (hasComment)
                  Row(
                    children: [
                      Text(
                        '한줄평',
                        style: MITITextStyle.xxsm
                            .copyWith(color: MITIColor.gray100),
                      ),
                      SizedBox(width: 20.w),
                      const BoxSkeleton(
                          width: 247, height: 28, borderRadius: 12),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
