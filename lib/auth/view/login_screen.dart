import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:miti/auth/error/auth_error.dart';
import 'package:miti/auth/provider/login_provider.dart';
import 'package:miti/auth/view/find_info/find_info_screen.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_screen.dart';
import 'package:miti/auth/view/signup/signup_select_screen.dart';
import 'package:miti/common/provider/form_util_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common/component/custom_text_form_field.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/default_model.dart';
import '../../default_screen.dart';
import '../../dio/response_code.dart';
import '../../court/view/court_map_screen.dart';
import '../param/auth_param.dart';

class LoginScreen extends StatelessWidget {
  static String get routeName => 'login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 24.h),
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
              'Make it, Take it!',
              style: TextStyle(
                  fontSize: 14.sp,
                  letterSpacing: -0.25.sp,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36.h),
            const LoginComponent(),
            Text(
              '또는',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                letterSpacing: -0.25.sp,
                color: const Color(0xFF8C8C8C),
              ),
            ),
            SizedBox(height: 8.h),
            const KakaoLoginButton(),
            SizedBox(height: 4.h),
            if(Platform.isIOS)
            const AppleLoginButton(),
            SizedBox(height: 16.h),
            OtherWayComponent(
              desc: '아직 회원이 아니신가요?',
              way: '회원가입하기',
              onTap: () => context.pushNamed(SignUpSelectScreen.routeName),
            ),
            const Spacer(),
            const HelpComponent(),
          ],
        ),
      ),
    );
  }
}

class LoginComponent extends ConsumerStatefulWidget {
  const LoginComponent({super.key});

  @override
  ConsumerState<LoginComponent> createState() => _LoginComponentState();
}

class _LoginComponentState extends ConsumerState<LoginComponent> {
  final formKey = GlobalKey<FormState>();
  late final List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
  InteractionDesc? interactionDesc;

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    for (var focusNode in focusNodes) {
      focusNode.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    for (var focusNode in focusNodes) {
      focusNode.removeListener(() {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loginFormProvider);

    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            focusNode: focusNodes[0],
            textEditingController: emailController,
            hintText: '이메일을 입력해주세요.',
            textInputAction: TextInputAction.next,
            label: '이메일',
            onNext: () => FocusScope.of(context).requestFocus(focusNodes[1]),
            suffixIcon: focusNodes[0].hasFocus
                ? IconButton(
                    onPressed: () {
                      emailController.clear();
                      ref
                          .read(loginFormProvider.notifier)
                          .updateFormField(email: '');
                    },
                    icon: SvgPicture.asset(
                      'assets/images/btn/close_btn.svg',
                    ),
                  )
                : null,
            onChanged: (String? val) {
              ref.read(loginFormProvider.notifier).updateFormField(email: val);
              log(ref.read(loginFormProvider).email);
            },
          ),
          SizedBox(height: 20.h),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final interactionDesc =
                  ref.watch(formDescProvider(InputFormType.login));
              final isVisible =
                  ref.watch(passwordVisibleProvider(PasswordFormType.password));
              return CustomTextFormField(
                focusNode: focusNodes[1],
                textEditingController: passwordController,
                hintText: '8자리 이상의 PW를 입력해주세요.',
                textInputAction: TextInputAction.send,
                label: '비밀번호',
                obscureText: !isVisible,
                suffixIcon: focusNodes[1].hasFocus
                    ? IconButton(
                        onPressed: () {
                          ref
                              .read(passwordVisibleProvider(
                                      PasswordFormType.password)
                                  .notifier)
                              .update((state) => !state);
                        },
                        icon: Icon(isVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      )
                    : null,
                onChanged: (val) {
                  ref
                      .read(loginFormProvider.notifier)
                      .updateFormField(password: val);
                  log(ref.read(loginFormProvider).password);
                },
                onNext: () => login(),
                interactionDesc: interactionDesc,
              );
            },
          ),
          SizedBox(height: 20.h),
          TextButton(
            onPressed: () => login(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                ref.watch(loginFormProvider.notifier).isValid()
                    ? const Color(0xFF4065F6)
                    : const Color(0xFFE8E8E8),
              ),
            ),
            child: Text(
              '로그인 하기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                letterSpacing: -0.25.sp,
                color: ref.watch(loginFormProvider.notifier).isValid()
                    ? Colors.white
                    : const Color(0xFF969696),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  void login() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (ref.read(loginFormProvider.notifier).isValid()) {
      final result = await ref.read(loginProvider.future);
      if (mounted) {
        if (result is ErrorModel) {

          AuthError.fromModel(model: result)
              .responseError(context, AuthApiType.login, ref);
        } else {
          context.goNamed(CourtMapScreen.routeName);
        }
      }
    }
  }
}

class OtherWayComponent extends StatelessWidget {
  final String desc;
  final String way;
  final VoidCallback onTap;

  const OtherWayComponent(
      {super.key, required this.desc, required this.way, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          desc,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              letterSpacing: -0.25.sp,
              color: const Color(0xFF585757)),
        ),
        SizedBox(width: 18.w),
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                way,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: const Color(0xFF4065F6),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF4065F6)),
            ],
          ),
        )
      ],
    );
  }
}

class KakaoLoginButton extends ConsumerWidget {
  const KakaoLoginButton({super.key});

  void signInWithKakao(WidgetRef ref, BuildContext context) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      log('isInstalled =${isInstalled}');
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk().then((value) => value).catchError((e, _){
            log('kakao login fail');
      })
          : await UserApi.instance.loginWithKakaoAccount();
      log('token ${token}');
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
      log('token Info = ${tokenInfo}');
      log('access token ${token.accessToken}');
      final OauthLoginParam param =
          OauthLoginParam(access_token: token.accessToken);
      final result = await ref.read(oauthLoginProvider(param: param).future);
      if (result is ErrorModel) {
        AuthError.fromModel(model: result)
            .responseError(context, AuthApiType.oauth, ref);
        throw Exception();
      } else {
        if (context.mounted) {
          context.goNamed(CourtMapScreen.routeName);
        }
      }
    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        signInWithKakao(ref, context);
      },
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
            color: const Color(0xFFFAE64D),
            borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          children: [
            SizedBox(width: 23.w),
            Container(
              width: 24.w,
              height: 20.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo/kakao_logo.png'),
                ),
              ),
            ),
            SizedBox(width: 52.w),
            Text(
              '카카오로 3초만에 시작하기',
              style: TextStyle(
                color: const Color(0xFF1C1C1C),
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

class AppleLoginButton extends ConsumerWidget {
  const AppleLoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async{
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        print(credential);

        // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
        // after they have been validated with Apple (see `Integration` section for more information on how to do this)

      },
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
            color: const Color(0xFFFFFFF1),
            borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          children: [
            SizedBox(width: 23.w),
            Container(
              width: 24.w,
              height: 20.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo/kakao_logo.png'),
                ),
              ),
            ),
            SizedBox(width: 52.w),
            Text(
              '애플로 3초만에 시작하기',
              style: TextStyle(
                color: const Color(0xFF1C1C1C),
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


class HelpComponent extends StatelessWidget {
  const HelpComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14.sp,
      letterSpacing: -0.25.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF8C8C8C),
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {},
              child: Text(
                '고객센터',
                style: textStyle,
              ),
            ),
            Text(
              ' | ',
              style: textStyle,
            ),
            InkWell(
              onTap: () {
                context.pushNamed(
                  FindInfoScreen.routeName,
                );
              },
              child: Text(
                'ID / PW를 잊으셨나요?',
                style: textStyle,
              ),
            ),
          ],
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
