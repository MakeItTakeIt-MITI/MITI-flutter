import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';

import '../../../common/component/default_appbar.dart';

class SignUpSelectScreen extends StatelessWidget {
  static String get routeName => 'signUpSelect';

  const SignUpSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 153.h,
                bottom: 198.h,
              ),
              child: const _IntroductionComponent(),
            ),
            const _SignUpButton(),
            SizedBox(height: 35.h),
            OtherWayComponent(
                desc: '이미 가입하셨나요?',
                way: '로그인하기',
                onTap: () => context.goNamed(LoginScreen.routeName)),
            const Spacer(),
            const HelpComponent(),
          ],
        ),
      ),
    );
  }
}

class _IntroductionComponent extends StatelessWidget {
  const _IntroductionComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88.w,
          height: 28.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/logo/MITI.png'),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '만나서 반가워요!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.25.sp,
            fontSize: 24.sp,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '어떤 방식으로 MITI에 가입하시겠어요?',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            letterSpacing: -0.25.sp,
            fontSize: 14.sp,
            color: const Color(0xFF1C1C1C),
          ),
        )
      ],
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const EmailSignUpButton(),
        SizedBox(height: 8.h),
        const KakaoLoginButton(),
      ],
    );
  }
}

class EmailSignUpButton extends StatelessWidget {
  const EmailSignUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(SignUpScreen.routeName),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
            color: const Color(0xFF4065F6),
            borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          children: [
            SizedBox(width: 23.w),
            SizedBox(
              width: 24.r,
              height: 24.r,
              child: const Icon(
                Icons.email_outlined,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 61.w),
            Text(
              '이메일로 시작하기',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: -0.25.sp,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
