import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../common/model/entity_enum.dart';
import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import '../../../util/util.dart';

class ReviewDetailSkeleton extends StatelessWidget {
  final ReviewType reviewType;

  const ReviewDetailSkeleton({super.key, required this.reviewType});

  Widget getDivider() {
    return Divider(
      color: MITIColor.gray600,
      indent: 13.w,
      endIndent: 13.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserInfoSkeleton(
          reviewType: reviewType,
        ),
        getDivider(),
        const GameInfoSkeleton(),
        getDivider(),
        const ReviewInfoSkeleton(),
      ],
    );
  }
}

class UserInfoSkeleton extends StatelessWidget {
  final ReviewType reviewType;

  const UserInfoSkeleton({super.key, required this.reviewType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            reviewType == ReviewType.guest ? '리뷰 작성자' : '호스트',
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              CustomSkeleton(
                skeleton: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MITIColor.gray600,
                  ),
                  height: 36.r,
                  width: 36.r,
                ),
              ),
              SizedBox(width: 12.w),
              const BoxSkeleton(width: 98, height: 14),
            ],
          )
        ],
      ),
    );
  }
}

class GameInfoSkeleton extends StatelessWidget {
  const GameInfoSkeleton({super.key});

  Row getGameInfo({required String title, required double width}) {
    return Row(
      children: [
        Text(
          title,
          style: MITITextStyle.xxsmLight.copyWith(
            color: MITIColor.gray100,
          ),
        ),
        SizedBox(width: 4.w),
        BoxSkeleton(width: width, height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '경기 정보',
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 16.h),
          const BoxSkeleton(width: 330, height: 18),
          SizedBox(height: 8.h),
          getGameInfo(title: '경기 일시', width: 179),
          SizedBox(height: 4.h),
          getGameInfo(title: '경기 장소', width: 166),
          SizedBox(height: 4.h),
          getGameInfo(title: '참여 비용', width: 42),
        ],
      ),
    );
  }
}

class ReviewInfoSkeleton extends StatelessWidget {
  const ReviewInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final startList = List.generate(
      5,
      (_) => Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: CustomSkeleton(
          skeleton: SvgPicture.asset(
            AssetUtil.getAssetPath(type: AssetType.icon, name: 'skeleton_star'),
            width: 40.r,
            height: 40.r,
          ),
        ),
      ),
    ).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "리뷰 내용",
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 20.h),
          Text(
            '평점',
            style: MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray200),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              ...startList,
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            '잘했던 점',
            style: MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray200),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.r,
            runSpacing: 12.r,
            children: const [
              BoxSkeleton(
                width: 78,
                height: 34,
                borderRadius: 100,
              ),
              BoxSkeleton(
                width: 78,
                height: 34,
                borderRadius: 100,
              ),
              BoxSkeleton(
                width: 78,
                height: 34,
                borderRadius: 100,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            '한줄평',
            style: MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray200),
          ),
          SizedBox(height: 12.h),
          const BoxSkeleton(
            width: 330,
            height: 66,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
