import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';
import 'package:miti/theme/color_theme.dart';

class PushListSkeleton extends StatelessWidget {
  const PushListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      PushSkeleton(),
      PushSkeleton(),
      PushSkeleton(),
      PushSkeleton(),
      PushSkeleton(),
    ],);
  }
}

class PushSkeleton extends StatelessWidget {
  const PushSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MITIColor.gray600,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BoxSkeleton(height: 12, width: 70),
              BoxSkeleton(height: 12, width: 47),
            ],
          ),
          SizedBox(height: 16.h),
          const BoxSkeleton(height: 21, width: 330),
        ],
      ),
    );
  }
}
