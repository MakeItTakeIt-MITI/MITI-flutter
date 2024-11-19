import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

class TcPolicySkeleton extends StatelessWidget {
  const TcPolicySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BoxSkeleton(width: 175.w, height: 20.h),
        SizedBox(height: 10.h),
        BoxSkeleton(width: 175.w, height: 20.h),
        SizedBox(height: 10.h),
        BoxSkeleton(width: 175.w, height: 20.h),
        SizedBox(height: 10.h),
        BoxSkeleton(width: 175.w, height: 20.h),
        SizedBox(height: 10.h),
        BoxSkeleton(width: 175.w, height: 20.h),
      ],
    );
  }
}
