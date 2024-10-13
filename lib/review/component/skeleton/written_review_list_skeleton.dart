import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import '../../../util/util.dart';

class WrittenReviewListSkeleton extends StatelessWidget {
  const WrittenReviewListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, __) => const WrittenReviewSkeleton(),
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemCount: 4);
  }
}

class WrittenReviewSkeleton extends StatelessWidget {
  const WrittenReviewSkeleton({super.key});

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
                    const BoxSkeleton(width: 98, height: 14),
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
                    SizedBox(width: 32.w),
                    ...startList,
                    SizedBox(width: 6.w),
                    const BoxSkeleton(width: 19, height: 14),
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
                    SizedBox(width: 16.w),
                    const BoxSkeleton(width: 79, height: 34, borderRadius: 100),
                    SizedBox(width: 8.w),
                    const BoxSkeleton(width: 79, height: 34, borderRadius: 100),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      '한줄평',
                      style:
                          MITITextStyle.xxsm.copyWith(color: MITIColor.gray100),
                    ),
                    SizedBox(width: 20.w),
                    const BoxSkeleton(width: 230, height: 28, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ),
          SvgPicture.asset(AssetUtil.getAssetPath(
              type: AssetType.icon, name: 'chevron_right'))
        ],
      ),
    );
  }
}
