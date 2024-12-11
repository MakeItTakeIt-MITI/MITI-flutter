import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/account/component/skeleton/settlement_skeleton.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';

class SettlementDetailSkeleton extends StatelessWidget {
  const SettlementDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SettlementSkeleton(),
        SizedBox(height: 3.h),
        const SettlementInfoSkeleton(),
        SizedBox(height: 3.h),
        const ParticipationSkeleton()
      ],
    );
  }
}

class SettlementInfoSkeleton extends StatelessWidget {
  const SettlementInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MITIColor.gray750,
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '정산 정보',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '경기 참여 비용',
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              const BoxSkeleton(width: 57, height: 14),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '정산 수수료',
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              const BoxSkeleton(width: 50, height: 14),
            ],
          ),
          Divider(height: 41.h, color: MITIColor.gray600),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재 정산 금액',
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              const BoxSkeleton(width: 72, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class ParticipationSkeleton extends StatelessWidget {
  const ParticipationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MITIColor.gray750,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 24.h,
              left: 21.w,
              right: 21.w,
              bottom: 20.h,
            ),
            child: Text(
              '참여자 정산 정보',
              style: MITITextStyle.mdBold.copyWith(
                color: MITIColor.gray100,
              ),
            ),
          ),
          ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, idx) {
                return const ParticipationCardSkeleton();
              },
              separatorBuilder: (_, idx) {
                return const Divider(
                  color: MITIColor.gray600,
                );
              },
              itemCount: 10),
        ],
      ),
    );
  }
}

class ParticipationCardSkeleton extends StatelessWidget {
  const ParticipationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 21.w,
        vertical: 20.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BoxSkeleton(width: 50, height: 18),
          const Spacer(),
          const BoxSkeleton(width: 84, height: 14),
          SizedBox(width: 20.w),
          const BoxSkeleton(width: 57, height: 18),
        ],
      ),
    );
  }
}
