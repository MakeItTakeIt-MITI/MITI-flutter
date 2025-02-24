import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/component/skeleton.dart';

class GameSearchSkeleton extends StatelessWidget {
  const GameSearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _GameSearchCardSkeleton(),
        _GameSearchCardSkeleton(),
        _GameSearchCardSkeleton(),
      ],
    );
  }
}

class _GameSearchCardSkeleton extends StatelessWidget {
  const _GameSearchCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(
          color: Color(0xFF4B4B4B),
        ),
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxSkeleton(height: 18.h, width: 45.w),
                  SizedBox(height: 8.h),
                  BoxSkeleton(height: 16.h, width: 244.w),
                ],
              ),
              BoxSkeleton(height: 34.h, width: 36.w),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxSkeleton(height: 16.h, width: 89.w),
                  SizedBox(height: 4.h),
                  BoxSkeleton(height: 16.h, width: 98.w),
                ],
              ),
              BoxSkeleton(height: 16.h, width: 50.w),
            ],
          )
        ],
      ),
    );
  }
}
