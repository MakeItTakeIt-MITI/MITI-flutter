import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
              style: TextStyle(
                color: const Color(0xFF040000),
                fontSize: 18.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 28 / 18,
                letterSpacing: -0.25.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              content,
              style: TextStyle(
                color: const Color(0xFF040000),
                fontSize: 14.sp,
                height: 22 / 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.25.sp,
              ),
            ),
            SizedBox(height: 16.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 34.h),
              child: TextButton(
                onPressed: onPressed ?? () => context.pop(),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r))),
                child: Text(
                  '확인',
                  // style: TextStyle(
                  //   color: Colors.white,
                  //   fontSize: 14.sp,
                  //   fontFamily: 'Pretendard',
                  //   height: 22 / 14,
                  //   fontWeight: FontWeight.w600,
                  //   letterSpacing: -0.25.sp,
                  // ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
