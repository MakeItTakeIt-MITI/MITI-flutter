import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:miti/auth/provider/login_provider.dart';
import 'package:miti/auth/view/find_info/find_info_screen.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_screen.dart';
import 'package:miti/auth/view/signup/signup_select_screen.dart';

import '../../common/component/custom_text_form_field.dart';
import '../../common/model/default_model.dart';
import '../../dio/response_code.dart';
import '../param/auth_param.dart';

class LoginScreen extends StatelessWidget {
  static String get routeName => 'login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          // leading: IconButton(
          //   onPressed: () => context.pop(),
          //   icon: const Icon(Icons.chevron_left),
          // ),
          ),
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
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const LoginComponent(),
            Text(
              '또는',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: const Color(0xFF8C8C8C),
              ),
            ),
            SizedBox(height: 8.h),
            const KakaoLoginButton(),
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
  bool isVisible = false;
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
                    icon: CircleAvatar(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF585757),
                      maxRadius: 14.r,
                      child: Icon(
                        Icons.close,
                        size: 20.r,
                      ),
                    ),
                  )
                : null,
            onChanged: (String? val) {
              ref.read(loginFormProvider.notifier).updateFormField(email: val);
              log(ref.read(loginFormProvider).email);
            },
          ),
          SizedBox(height: 14.h),
          CustomTextFormField(
            focusNode: focusNodes[1],
            textEditingController: passwordController,
            hintText: '8자리 이상의 PW를 입력해주세요.',
            textInputAction: TextInputAction.send,
            label: '비밀번호',
            obscureText: !isVisible,
            suffixIcon: focusNodes[1].hasFocus
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
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
          ),
          SizedBox(height: 46.h),
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
    if (ref.read(loginFormProvider.notifier).isValid()) {
      final result = await ref.read(loginProvider.future);
      if (result is ErrorModel) {
        final model = result;
        log('model.status_code == Forbidden ${model.status_code}');
        if (model.status_code == Forbidden && context.mounted) {
          context.pushNamed(PhoneAuthScreen.routeName);
        }
        setState(() {
          interactionDesc = InteractionDesc(
            isSuccess: false,
            desc: "일치하는 사용자 정보가 존재하지 않습니다.",
          );
        });
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

  void signInWithKakao(WidgetRef ref) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      log('token ${token}');
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
      log('token Info = ${tokenInfo}');
      log('access token ${token.accessToken}');
      final OauthLoginParam param =
          OauthLoginParam(access_token: token.accessToken);
      final result = await ref.read(oauthLoginProvider(param: param).future);
      if (result is ErrorModel) {
        throw Exception();
      }
    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        signInWithKakao(ref);
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
                Map<String, String> queryParameters = {'findInfo': 'email'};
                context.pushNamed(FindInfoScreen.routeName,
                    queryParameters: queryParameters);
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
