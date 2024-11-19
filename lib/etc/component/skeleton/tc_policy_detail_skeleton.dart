import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../common/component/default_appbar.dart';
import '../../../theme/color_theme.dart';

class TcPolicyDetailSkeleton extends StatelessWidget {
  const TcPolicyDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray800,
      appBar: const DefaultAppBar(
        hasBorder: false,
        leadingIcon: "remove",
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 21.w,
          vertical: 24.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoxSkeleton(width: 207.w, height: 30.h),
            SizedBox(height: 20.h),
            const _TcPolicyContentSkeleton(),
            const Spacer(),
            TextButton(
                onPressed: () => context.pop(), child: const Text("닫기")),
          ],
        ),
      ),
    );
  }
}

class _TcPolicyContentSkeleton extends StatelessWidget {
  const _TcPolicyContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxSkeleton(width: double.infinity, height: 16.h),
        SizedBox(height: 3.h),
        BoxSkeleton(width: double.infinity, height: 16.h),
        SizedBox(height: 3.h),
        BoxSkeleton(width: 113.w, height: 16.h),
        SizedBox(height: 25.h),
        BoxSkeleton(width: double.infinity, height: 16.h),
        SizedBox(height: 3.h),
        BoxSkeleton(width: 200.w, height: 16.h),
        SizedBox(height: 3.h),
        BoxSkeleton(width: double.infinity, height: 16.h),
        SizedBox(height: 3.h),
        BoxSkeleton(width: double.infinity, height: 16.h),
        SizedBox(height: 3.h),
        BoxSkeleton(width: 167.w, height: 16.h),
      ],
    );
  }
}
