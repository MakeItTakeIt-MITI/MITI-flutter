import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class PostBottomSheetButton extends StatelessWidget {
  final bool isWriter;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onReport;

  const PostBottomSheetButton(
      {super.key,
      required this.isWriter,
      required this.onDelete,
      required this.onUpdate,
      required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWriter)
            Column(
              children: [
                SizedBox(
                  height: 48.h,
                  child: TextButton(
                    onPressed:onDelete,
                    style: TextButton.styleFrom(
                        backgroundColor: MITIColor.gray800),
                    child: Text(
                      "삭제하기",
                      style: MITITextStyle.md.copyWith(color: V2MITIColor.red5),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                SizedBox(
                  height: 48.h,
                  child: TextButton(
                    onPressed:onUpdate,
                    style: TextButton.styleFrom(
                        backgroundColor: MITIColor.gray800),
                    child: Text(
                      "수정하기",
                      style:
                          MITITextStyle.md.copyWith(color: MITIColor.gray100),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              height: 48.h,
              child: TextButton(
                onPressed:onReport,
                style: TextButton.styleFrom(backgroundColor: MITIColor.gray800),
                child: Text(
                  "신고하기",
                  style: MITITextStyle.md.copyWith(color: V2MITIColor.red5),
                ),
              ),
            ),
          SizedBox(
            height: 15.h,
          ),
          TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(backgroundColor: MITIColor.gray800),
              child: Text(
                "닫기",
                style: MITITextStyle.md.copyWith(color: MITIColor.gray400),
              )),
        ],
      ),
    );
  }
}
