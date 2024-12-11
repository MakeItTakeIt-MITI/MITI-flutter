import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/component/skeleton.dart';
import '../../../theme/color_theme.dart';

class CourtListSkeleton extends StatelessWidget {
  const CourtListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _CourtCardListSkeleton(),
      ],
    );
  }
}

class _CourtCardListSkeleton extends StatelessWidget {
  const _CourtCardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (_, __) => const _CourtCardSkeleton(),
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemCount: 10);
  }
}

class _CourtCardSkeleton extends StatelessWidget {
  const _CourtCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: MITIColor.gray700,
        border: Border.all(
          color: MITIColor.gray600,
        ),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(height: 18, width: 300),
          SizedBox(height: 4.h),
          const BoxSkeleton(height: 12, width: 170),
        ],
      ),
    );
  }
}
