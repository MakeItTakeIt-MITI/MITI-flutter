import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/account/component/bank_card.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';

class GameDetailSkeleton extends StatelessWidget {
  const GameDetailSkeleton({super.key});

  Widget getDivider() {
    return Container(
      height: 3.h,
      color: MITIColor.gray800,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SummarySkeleton(),
        getDivider(),
        const ParticipationInfoSkeleton(),
        getDivider(),
        const HostSkeleton(),
        getDivider(),
        const GameInfoSkeleton(),
      ],
    );
  }
}

class SummarySkeleton extends StatelessWidget {
  const SummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const BoxSkeleton(width: 37, height: 18),
          SizedBox(height: 12.h),
          const BoxSkeleton(width: 330, height: 16),
          SizedBox(height: 8.h),
          const BoxSkeleton(width: 158, height: 14),
          SizedBox(height: 20.h),
          const BoxSkeleton(width: 61, height: 14),
          SizedBox(height: 4.h),
          const BoxSkeleton(width: 251, height: 14),
          SizedBox(height: 4.h),
          const BoxSkeleton(width: 49, height: 14),
          SizedBox(height: 20.h),
          const BoxSkeleton(width: 130, height: 16),
        ],
      ),
    );
  }
}

class ParticipationInfoSkeleton extends StatelessWidget {
  const ParticipationInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 170, height: 16),
          SizedBox(height: 20.h),
          SizedBox(
            height: 60.r,
            child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, idx) {
                  return const ParticipationCardSkeleton();
                },
                separatorBuilder: (_, idx) {
                  return SizedBox(width: 12.w);
                },
                itemCount: 10),
          ),
        ],
      ),
    );
  }
}

class ParticipationCardSkeleton extends StatelessWidget {
  const ParticipationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSkeleton(
          skeleton: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: MITIColor.gray600,
            ),
            width: 36.r,
            height: 36.r,
          ),
        ),
        SizedBox(height: 8.h),
        const BoxSkeleton(width: 45, height: 12),
      ],
    );
  }
}

class HostSkeleton extends StatelessWidget {
  const HostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 103, height: 16),
          SizedBox(height: 20.h),
          Row(
            children: [
              CustomSkeleton(
                skeleton: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MITIColor.gray600,
                  ),
                  width: 36.r,
                  height: 36.r,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                children: [
                  const BoxSkeleton(width: 98, height: 14),
                  SizedBox(height: 8.h),
                  const BoxSkeleton(width: 105, height: 14),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
class GameInfoSkeleton extends StatelessWidget {
  const GameInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 97, height: 16),
          SizedBox(height: 20.h),
          const BoxSkeleton(width: 330, height: 21),
          SizedBox(height: 7.h),
          const BoxSkeleton(width: 330, height: 21),
          SizedBox(height: 7.h),
          const BoxSkeleton(width: 196, height: 21),
          SizedBox(height: 7.h),
          const BoxSkeleton(width: 330, height: 21),
          SizedBox(height: 7.h),
          const BoxSkeleton(width: 330, height: 21),
          SizedBox(height: 7.h),
          const BoxSkeleton(width: 227, height: 21),
        ],
      ),
    );
  }
}
