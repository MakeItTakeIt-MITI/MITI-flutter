import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/theme/text_theme.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onPressed;

  const CustomDialog(
      {super.key, required this.title, this.onPressed, required this.content});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 348.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: MITITextStyle.popupTitleStyle.copyWith(
                color: const Color(0xFF1A1E27),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              content,
              style: MITITextStyle.popupTextStyle.copyWith(
                color: const Color(0xFF1A1E27),
              ),
            ),
            SizedBox(height: 16.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 34.h),
              child: TextButton(
                onPressed: onPressed ??
                    () => Navigator.of(context, rootNavigator: true)
                        .pop('dialog'),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r))),
                child: Text(
                  '확인',
                  style: MITITextStyle.btnTextBStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
