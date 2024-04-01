import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';

class FindPasswordByEmailScreen extends StatelessWidget {
  static String get routeName => 'findPasswordByEmail';

  final String email;

  const FindPasswordByEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '회원 정보 찾기',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF000000),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 228.h),
            Text(
              '$email 계정으로 메일을 전송하였습니다.',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF333333),
              ),
            ),
            Text(
              '메일의 안내에 따라 비밀번호를 다시 설정해주세요.',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF333333),
              ),
            ),
            const Spacer(),
            TextButton(
                onPressed: () => context.goNamed(LoginScreen.routeName),
                child: const Text('로그인하기')),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
