import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';

import '../../common/component/skeleton.dart';

class NoticeListSkeleton extends StatelessWidget {
  const NoticeListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      NoticeSkeleton(),
      NoticeSkeleton(),
      NoticeSkeleton(),
      NoticeSkeleton(),
      NoticeSkeleton(),
      NoticeSkeleton(),
      NoticeSkeleton(),
      NoticeSkeleton(),
      NoticeSkeleton(),
      NoticeSkeleton(),
    ],);
  }
}

class NoticeSkeleton extends StatelessWidget {
  const NoticeSkeleton({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(height: 14, width: 330),
          SizedBox(height: 8.h),
          const BoxSkeleton(height: 12, width: 92),
        ],
      ),
    );
  }
}
