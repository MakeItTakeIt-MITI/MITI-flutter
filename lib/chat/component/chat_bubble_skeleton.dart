import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

class ChatBubbleSkeleton extends StatelessWidget {
  const ChatBubbleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSkeleton(
      skeleton: Column(
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: BoxSkeleton(width: double.infinity, height: 28.h),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 20.h),
            child: Column(
              children: [
                _ChatBubbleSkeleton(
                  height: 44.h,
                ),
                SizedBox(height: 11.h),
                _ChatBubbleSkeleton(
                  height: 184.h,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubbleSkeleton extends StatelessWidget {
  final double height;

  const _ChatBubbleSkeleton({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12.r,
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BoxSkeleton(width: 60.w, height: 12.h),
                SizedBox(width: 5.w),
                BoxSkeleton(width: 37.w, height: 12.h),
              ],
            ),
            SizedBox(height: 4.h),
            BoxSkeleton(width: 240.w, height: height),
          ],
        )
      ],
    );
  }
}
