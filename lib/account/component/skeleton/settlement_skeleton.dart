import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';

class SettlementListSkeleton extends StatelessWidget {
  const SettlementListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (_, __) => const SettlementSkeleton(),
        separatorBuilder: (_, __) => SizedBox(
              height: 8.h,
            ),
        itemCount: 3);
  }
}

class SettlementSkeleton extends StatelessWidget {
  const SettlementSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 20.h, bottom: 24.h),
      color: MITIColor.gray750,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 330, height: 24),
          SizedBox(height: 20.h),
          const BoxSkeleton(width: 180, height: 12),
          SizedBox(height: 8.h),
          const BoxSkeleton(width: 180, height: 12),
          SizedBox(height: 28.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const BoxSkeleton(width: 58, height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const BoxSkeleton(width: 100, height: 12),
                  SizedBox(height: 8.h),
                  const BoxSkeleton(width: 100, height: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
