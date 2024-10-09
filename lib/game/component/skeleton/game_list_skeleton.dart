import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';
import 'package:miti/theme/color_theme.dart';

class GameListSkeleton extends StatelessWidget {
  const GameListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _GameCardListSkeleton(),
        _GameCardListSkeleton(),
        _GameCardListSkeleton(),
      ],
    );
  }
}

class _GameCardListSkeleton extends StatelessWidget {
  const _GameCardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const BoxSkeleton(height: 14, width: 143),
          SizedBox(height: 12.h),
          const _GameCardSkeleton(),
          SizedBox(height: 12.h),
          const _GameCardSkeleton(),
        ],
      ),
    );
  }
}

class _GameCardSkeleton extends StatelessWidget {
  const _GameCardSkeleton({super.key});

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
          const BoxSkeleton(height: 18, width: 37),
          SizedBox(height: 8.h),
          const BoxSkeleton(height: 18, width: 300),
          SizedBox(height: 8.h),
          const BoxSkeleton(height: 18, width: 160),
        ],
      ),
    );
  }
}
