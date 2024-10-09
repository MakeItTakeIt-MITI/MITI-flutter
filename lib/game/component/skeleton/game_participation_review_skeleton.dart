import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';
import '../../../util/util.dart';

class GameParticipationReviewSkeleton extends StatelessWidget {
  const GameParticipationReviewSkeleton({super.key});

  Widget getDivider() {
    return Container(
      height: 4.h,
      color: MITIColor.gray900,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HostSkeleton(),
        getDivider(),
        const GuestSkeleton(),
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
          const BoxSkeleton(width: 53, height: 18),
          SizedBox(height: 12.h),
          const PlayerSkeleton(),
        ],
      ),
    );
  }
}

class GuestSkeleton extends StatelessWidget {
  const GuestSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 53, height: 18),
          SizedBox(height: 12.h),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, idx) {
              return const PlayerSkeleton();
            },
            separatorBuilder: (_, idx) {
              return Container(
                height: 12.h,
              );
            },
            shrinkWrap: true,
            itemCount: 10,
          )
        ],
      ),
    );
  }
}

class PlayerSkeleton extends StatelessWidget {
  const PlayerSkeleton({super.key});

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
          color: MITIColor.gray700,
          border: Border.all(color: MITIColor.gray600)),
      padding: EdgeInsets.all(16.r),
      alignment: Alignment.center,
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BoxSkeleton(width: 98, height: 14),
                SizedBox(height: 4.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...startList,
                      SizedBox(width: 6.w),
                      const BoxSkeleton(width: 19, height: 14),
                      SizedBox(width: 6.w),
                      const BoxSkeleton(width: 36, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Spacer(),
          const BoxSkeleton(
            width: 75,
            height: 30,
            borderRadius: 20,
          ),
        ],
      ),
    );
  }
}
