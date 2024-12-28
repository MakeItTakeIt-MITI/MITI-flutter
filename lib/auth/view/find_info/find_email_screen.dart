import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:miti/auth/view/find_info/find_info_screen.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/auth/view/signup/signup_select_screen.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../common/model/entity_enum.dart';
import '../../../util/util.dart';
import '../../provider/widget/find_info_provider.dart';
import 'find_password_screen.dart';

class FindEmailScreen extends StatelessWidget {
  final String findEmail;

  static String get routeName => 'findEmail';

  const FindEmailScreen({super.key, required this.findEmail});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '회원 정보 찾기',
          hasBorder: false,
          canPop: false,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: _EmailComponent(email: findEmail),
        ),
      ),
    );
  }
}

class OtherAccountScreen extends StatelessWidget {
  static String get routeName => 'otherAccount';
  final PhoneAuthType phoneType;
  final AuthType authType;

  const OtherAccountScreen(
      {super.key, required this.authType, required this.phoneType});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '회원 정보 찾기',
          hasBorder: false,
          canPop: false,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: _OauthComponent(
            authType: authType,
            phoneType: phoneType,
          ),
        ),
      ),
    );
  }
}

class NotFoundAccountScreen extends StatelessWidget {
  static String get routeName => 'notFoundAccount';

  const NotFoundAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '회원 정보 찾기',
          hasBorder: false,
          canPop: false,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Column(
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
                textAlign: TextAlign.center,
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
          ),
        ),
      ),
    );
  }
}

class _OauthComponent extends StatelessWidget {
  final AuthType authType;
  final PhoneAuthType phoneType;

  const _OauthComponent(
      {super.key, required this.authType, required this.phoneType});

  @override
  Widget build(BuildContext context) {
    String desc = authType == AuthType.kakao ? "카카오" : "Apple ID";

    return Column(
      children: <Widget>[
        const Spacer(),
        Lottie.asset(
          'assets/lottie/success2.json',
          width: 100.r,
          height: 100.r,
          fit: BoxFit.fill,
          repeat: false,
        ),
        SizedBox(height: 20.h),
        Text(
          phoneType == PhoneAuthType.find_email ? "이메일 찾기" : "비밀번호 찾기",
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
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final model = ref.read(findEmailProvider);

                  return TextButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                        MITIColor.gray700,
                      )),
                      onPressed: () {
                        Map<String, String> queryParameters = {
                          "password_update_token":
                              model!.password_update_token ?? '',
                          "userId": model.id.toString(),
                        };

                        context.goNamed(ResetPasswordScreen.routeName,
                            queryParameters: queryParameters);
                      },
                      child: Text(
                        '비밀번호 재설정',
                        style: MITITextStyle.mdBold.copyWith(
                          color: MITIColor.primary,
                        ),
                      ));
                },
              ),
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
