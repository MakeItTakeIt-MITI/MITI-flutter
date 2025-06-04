import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

class ChatNoticeSkeleton extends StatelessWidget {
  const ChatNoticeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.r),

      child: Column(
        children: [
          const _ChatNoticeItemSkeleton(),
          SizedBox(height: 10.h),
          const _ChatNoticeItemSkeleton(),
          SizedBox(height: 10.h),
          const _ChatNoticeItemSkeleton()
        ],
      ),
    );
  }
}

class _ChatNoticeItemSkeleton extends StatelessWidget {
  const _ChatNoticeItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxSkeleton(width: double.infinity, height: 14.h),
        SizedBox(height: 4.h),
        BoxSkeleton(width: 82.h, height: 10.h),
      ],
    );
  }
}
