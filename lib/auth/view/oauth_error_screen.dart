import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/component/default_appbar.dart';

class OauthErrorScreen extends StatelessWidget {
  static String get routeName => 'oauthError';

  const OauthErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 208.h),
            Text(
              '이메일 가입 사용자',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 25.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 40 / 25,
                letterSpacing: -0.25.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '이메일로 가입한 기록이 있습니다!\n이메일과 비밀번호를 통해 로그인해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 22 / 16,
                letterSpacing: -0.25.sp,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.goNamed(LoginScreen.routeName),
              child: const Text('로그인하기'),
            ),
            SizedBox(height: 15.h),
          ],
        ),
      ),
    );
  }
}
