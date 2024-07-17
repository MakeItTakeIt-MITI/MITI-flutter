import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/find_info/find_info_screen.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/auth/view/signup/signup_select_screen.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../common/model/entity_enum.dart';
import '../../../util/util.dart';
import 'find_password_screen.dart';

class FindEmailScreen extends StatelessWidget {
  final AuthType? authType;
  final String? findEmail;

  static String get routeName => 'findEmail';

  const FindEmailScreen({super.key, this.findEmail, this.authType});

  Widget getEmailComponent() {
    if (findEmail != null) {
      return _EmailComponent(email: findEmail!);
    } else if (authType != null) {
      return _OauthComponent(
        authType: authType!,
      );
    }
    return const NotFoundInfoComponent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: '회원 정보 찾기',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21.w),
        child: getEmailComponent(),
      ),
    );
  }
}

class NotFoundInfoComponent extends StatelessWidget {
  const NotFoundInfoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Text(
          "유저 정보 없음",
          style: MITITextStyle.xxl140.copyWith(
            color: MITIColor.white,
          ),
        ),
        SizedBox(height: 40.h),
        Text(
          "일치하는 사용자 정보가 존재하지 않습니다.\n회원가입시 입력한 전화번호를 확인해주세요.",
          style: MITITextStyle.sm150.copyWith(
            color: MITIColor.gray300,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            context.goNamed(SignUpSelectScreen.routeName);
          },
          child: const Text("회원가입 하기"),
        ),
        SizedBox(height: 41.h),
      ],
    );
  }
}

class _OauthComponent extends StatelessWidget {
  final AuthType authType;

  const _OauthComponent({super.key, required this.authType});

  @override
  Widget build(BuildContext context) {
    String desc = authType == AuthType.kakao ? "카카오" : "Apple ID";

    return Column(
      children: <Widget>[
        const Spacer(),
        Text(
          "이메일 찾기",
          style: MITITextStyle.xxl140.copyWith(
            color: MITIColor.white,
          ),
        ),
        SizedBox(height: 40.h),
        SvgPicture.asset(
          AssetUtil.getAssetPath(
              type: AssetType.logo, name: '${authType.name}_logo'),
          width: 32.r,
          height: 32.r,
        ),
        SizedBox(height: 12.h),
        Text(
          "회원님은 $desc로 가입하셨습니다!\n$desc 로그인을 통해 서비스를 이용해주세요.",
          style: MITITextStyle.sm150.copyWith(
            color: MITIColor.gray300,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            context.goNamed(LoginScreen.routeName);
          },
          child: const Text("로그인 하러 하기"),
        ),
        SizedBox(height: 41.h),
      ],
    );
  }
}

class _EmailComponent extends StatelessWidget {
  final String email;

  const _EmailComponent({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          '이메일 찾기',
          style: MITITextStyle.xxl140.copyWith(
            color: MITIColor.white,
          ),
        ),
        SizedBox(height: 40.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            color: MITIColor.gray700,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 16.h,
          ),
          alignment: Alignment.center,
          child: Text(
            email,
            style: MITITextStyle.md.copyWith(
              color: MITIColor.gray100,
            ),
          ),
        ),
        SizedBox(height: 40.h),
        Text(
          "혹시 비밀번호도 잊으셨나요?\n비밀번호 찾기를 통해 비밀번호를 재설정해주세요!",
          style: MITITextStyle.sm150.copyWith(
            color: MITIColor.gray300,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                    MITIColor.gray700,
                  )),
                  onPressed: () {},
                  child: Text(
                    '비밀번호 찾기',
                    style: MITITextStyle.mdBold.copyWith(
                      color: MITIColor.primary,
                    ),
                  )),
            ),
            SizedBox(width: 7.w),
            Expanded(
              child: TextButton(
                  onPressed: () => context.goNamed(LoginScreen.routeName),
                  child: const Text('로그인하기')),
            ),
          ],
        ),
        SizedBox(height: 41.h),
      ],
    );
  }
}
