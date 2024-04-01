import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/find_info/find_info_screen.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/component/custom_text_form_field.dart';

class FindEmailScreen extends StatelessWidget {
  final bool isOauth;
  final String findEmail;

  static String get routeName => 'findEmail';

  const FindEmailScreen(
      {super.key, required this.findEmail, required this.isOauth});

  @override
  Widget build(BuildContext context) {
    Widget getDesc() {
      final svg = isOauth ? 'kakao_icon' : 'none_icon';
      final desc = isOauth
          ? '회원님은 카카오로 가입하셨습니다!\n카카오 로그인을 통해 서비스를 이용해주세요.'
          : '혹시 비밀번호도 잊으셨나요?\n비밀번호 찾기를 통해 비밀번호를 재설정해주세요!';
      return Row(
        children: [
          SvgPicture.asset(
            'assets/images/icon/$svg.svg',
            width: 30.r,
            height: 30.r,
          ),
          SizedBox(width: 7.w),
          Column(
            children: [
              Text(desc,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF000000),
                  ))
            ],
          )
        ],
      );
    }

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 106.h),
            Text(
              '아이디 찾기',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 12.h),
            getDesc(),
            SizedBox(height: 12.h),
            CustomTextFormField(
              initialValue: findEmail,
              hintText: '',
              label: '',
              enabled: false,
            ),
            SizedBox(height: 12.h),
            InkWell(
                onTap: () {
                  Map<String, String> queryParameters = {
                    'findInfo': 'password'
                  };
                  context.goNamed(FindInfoScreen.routeName,
                      queryParameters: queryParameters);
                },
                child: Text(
                  'PW를 잊으셨나요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8C8C8C),
                  ),
                )),
            const Spacer(),
            TextButton(
                onPressed: () => context.goNamed(LoginScreen.routeName),
                child: const Text('로그인하기')),
            SizedBox(height: 14.h),
          ],
        ),
      ),
    );
  }
}
