import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class ChatMemberSkeleton extends StatelessWidget {
  const ChatMemberSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final guests = List.generate(4, (i) {
      return const _MemberSkeleton();
    }).toList();
    return Column(
      children: [
        const _ChatMemberComponentSkeleton(
          title: "호스트",
          children: [
            _MemberSkeleton(
              isHost: true,
            )
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
        _ChatMemberComponentSkeleton(
          title: "게스트",
          children: [...guests],
        )
      ],
    );
  }
}

class _ChatMemberComponentSkeleton extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ChatMemberComponentSkeleton({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Text(
            title,
            style: MITITextStyle.lgBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
        ),
        ListView.separated(
            shrinkWrap: true,
            itemBuilder: (_, idx) => children[idx],
            separatorBuilder: (_, idx) => SizedBox(height: 5.h),
            itemCount: children.length),
      ],
    );
  }
}

class _MemberSkeleton extends StatelessWidget {
  final bool isHost;

  const _MemberSkeleton({
    super.key,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.5.h),
      child: Row(
        children: [
          CustomSkeleton(
            skeleton: CircleAvatar(
              radius: 16.r,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    BoxSkeleton(width: 110.w, height: 12.h),
                    SizedBox(width: 5.w),
                    Visibility(
                      visible: isHost,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.r),
                          color: MITIColor.gray600,
                        ),
                        child: Text(
                          "호스트",
                          style: MITITextStyle.xxxsmBold
                              .copyWith(color: MITIColor.primary),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8.h),
                BoxSkeleton(width: 193.w, height: 14.h),
              ],
            ),
          )
        ],
      ),
    );
  }
}
