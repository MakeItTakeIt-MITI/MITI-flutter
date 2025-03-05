import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import '../../../util/util.dart';
import '../../view/profile_menu_screen.dart';

class ReceiveReviewSkeleton extends StatelessWidget {
  const ReceiveReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '내가 받은 리뷰 평점',
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              OverlayTooltipDemo(),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: _ReviewCardSkeleton()),
              SizedBox(width: 9.w),
              const Expanded(child: _ReviewCardSkeleton()),
            ],
          )
        ],
      ),
    );
  }
}

class _ReviewCardSkeleton extends StatelessWidget {
  const _ReviewCardSkeleton({super.key});

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: MITIColor.gray750,
      ),
      height: 82.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const BoxSkeleton(height: 12, width: 75),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...startList,
              SizedBox(width: 8.w),
              const BoxSkeleton(height: 18, width: 27),
            ],
          )
        ],
      ),
    );
  }
}
