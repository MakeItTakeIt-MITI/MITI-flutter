import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../common/component/default_appbar.dart';
import '../../../common/model/entity_enum.dart';
import '../../../util/util.dart';

class SignUpSelectScreen extends StatelessWidget {
  static String get routeName => 'signUpSelect';

  const SignUpSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.black,
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(
        backgroundColor: MITIColor.black,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 41.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 129.5.h,
                // bottom: 198.h,
              ),
              child: const _IntroductionComponent(),
            ),
            const Spacer(),
            const _SignUpButton(),
            SizedBox(height: 32.h),
            OtherWayComponent(
                desc: '이미 가입하셨나요?',
                way: '로그인하기',
                onTap: () => context.goNamed(LoginScreen.routeName)),
            SizedBox(height: 100.h),
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
        SvgPicture.asset(
          AssetUtil.getAssetPath(type: AssetType.logo, name: 'MITI'),
          width: 110.w,
          height: 54.h,
        ),
        SizedBox(height: 25.5.h),
        Text(
          '만나서 반가워요!',
          style: MITITextStyle.xxl.copyWith(color: MITIColor.white),
        ),
        SizedBox(height: 12.h),
        Text(
          '어떤 방식으로 MITI에 가입하시겠어요?',
          style: MITITextStyle.sm.copyWith(color: MITIColor.white),
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
        SizedBox(height: 12.h),
        const KakaoLoginButton(),
        if (Platform.isIOS) SizedBox(height: 12.h),
        if (Platform.isIOS) const AppleLoginButton(),
      ],
    );
  }
}

class EmailSignUpButton extends StatelessWidget {
  const EmailSignUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        const extra = AuthType.email;
        context.goNamed(SignUpScreen.routeName, extra: extra);
      },
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
            color: MITIColor.primary, borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          children: [
            SizedBox(width: 20.w),
            Container(
              height: 24.r,
              width: 24.r,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    AssetUtil.getAssetPath(
                        type: AssetType.icon, name: 'Mail', extension: 'png'),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              '이메일로 시작하기',
              style: MITITextStyle.smBold.copyWith(
                color: MITIColor.gray800,
              ),
            ),
            SizedBox(width: 97.5.w),
          ],
        ),
      ),
    );
  }
}
