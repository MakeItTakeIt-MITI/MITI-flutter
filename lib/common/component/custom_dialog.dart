import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomDialog extends StatelessWidget {
  final String title;

  const CustomDialog({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
        ),
        padding:
            EdgeInsets.only(left: 12.w, right: 12.w, top: 30.h, bottom: 5.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF040000),
                fontSize: 12.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.25,
              ),
            ),
            SizedBox(height: 13.h),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(minimumSize: Size(60.w, 30.h)),
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.25,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
