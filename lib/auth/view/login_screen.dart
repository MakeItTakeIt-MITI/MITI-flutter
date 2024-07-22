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
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/provider/form_util_provider.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common/component/custom_text_form_field.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/widget/form_provider.dart';
import '../../default_screen.dart';
import '../../dio/response_code.dart';
import '../../court/view/court_map_screen.dart';
import '../../theme/color_theme.dart';
import '../param/auth_param.dart';
import '../provider/widget/sign_up_form_provider.dart';

class LoginScreen extends StatelessWidget {
  static String get routeName => 'login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.black,
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(
        backgroundColor: MITIColor.black,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 34.h),
            SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.logo, name: 'MITI'),
              width: 80.w,
              height: 42.h,
            ),
            SizedBox(height: 44.h),
            const LoginComponent(),
            Text(
              '또는',
              textAlign: TextAlign.center,
              style: MITITextStyle.xxsm.copyWith(
                color: const Color(0xFFEAEAEA),
              ),
            ),
            SizedBox(height: 12.h),
            const KakaoLoginButton(
              isLogin: true,
            ),
            SizedBox(height: 8.h),
            if (Platform.isIOS)
              const AppleLoginButton(
                isLogin: true,
              ),
            SizedBox(height: 16.h),
            OtherWayComponent(
              // desc: '아직 회원이 아니신가요?',
              way: '회원가입 하러 가기',
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
        // setState(() {});
      });
    }

    /// 폼 에러 메시지 미리 설정
    /// SizedBox로 공백 높이를 설정하려고 하니 부정확함
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(formInfoProvider(InputFormType.password).notifier)
          .update(interactionDesc: InteractionDesc(isSuccess: false, desc: ''));
    });
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
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final formInfo = ref.watch(formInfoProvider(InputFormType.email));

              return CustomTextFormField(
                focusNode: focusNodes[0],
                textEditingController: emailController,
                hintText: '이메일을 입력해주세요.',
                textInputAction: TextInputAction.next,
                label: '이메일',
                borderColor: formInfo.borderColor,
                onNext: () =>
                    FocusScope.of(context).requestFocus(focusNodes[1]),
                onChanged: (String? val) {
                  ref
                      .read(loginFormProvider.notifier)
                      .updateFormField(email: val);
                  log(ref.read(loginFormProvider).email);
                },
              );
            },
          ),
          SizedBox(height: 20.h),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final formInfo =
                  ref.watch(formInfoProvider(InputFormType.password));
              final isVisible =
                  ref.watch(passwordVisibleProvider(PasswordFormType.password));
              return Column(
                children: [
                  CustomTextFormField(
                    focusNode: focusNodes[1],
                    textEditingController: passwordController,
                    hintText: '패스워드를 입력해 주세요.',
                    textInputAction: TextInputAction.send,
                    label: '비밀번호',
                    obscureText: !isVisible,
                    borderColor: formInfo.borderColor,
                    suffixIcon: focusNodes[1].hasFocus
                        ? GestureDetector(
                            onTap: () {
                              ref
                                  .read(passwordVisibleProvider(
                                          PasswordFormType.password)
                                      .notifier)
                                  .update((state) => !state);
                            },
                            child: SvgPicture.asset(
                              AssetUtil.getAssetPath(
                                  type: AssetType.icon,
                                  name: isVisible ? 'visible' : 'invisible'),
                              width: 24.r,
                              height: 24.r,
                            ),
                          )
                        : null,
                    onChanged: (val) {
                      ref
                          .read(loginFormProvider.notifier)
                          .updateFormField(password: val);
                      log(ref.read(loginFormProvider).password);
                    },
                    onNext: () => login(),
                    interactionDesc: formInfo.interactionDesc,
                  ),
                  // if(formInfo.interactionDesc == null)
                  // SizedBox(height: 28.h),
                ],
              );
            },
          ),
          SizedBox(height: 32.h),
          TextButton(
            onPressed: () => login(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                ref.watch(loginFormProvider.notifier).isValid()
                    ? MITIColor.primary
                    : MITIColor.gray500,
              ),
            ),
            child: Text(
              '로그인 하기',
              style: MITITextStyle.smBold.copyWith(
                color: ref.watch(loginFormProvider.notifier).isValid()
                    ? MITIColor.gray800
                    : MITIColor.gray100,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  void login() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (ref.read(loginFormProvider.notifier).isValid()) {
      final param = ref.read(loginFormProvider);
      final result = await ref.read(loginProvider(
        param: param,
        type: AuthType.email,
      ).future);
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
  final String? desc;
  final String way;
  final VoidCallback onTap;

  const OtherWayComponent(
      {super.key, this.desc, required this.way, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (desc != null)
          Text(
            desc!,
            style: MITITextStyle.sm.copyWith(color: const Color(0xFFEAEAEA)),
          ),
        if (desc != null) SizedBox(width: 18.w),
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                way,
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.primary,
                ),
              ),
              SvgPicture.asset(
                AssetUtil.getAssetPath(
                    type: AssetType.icon, name: 'right_arrow'),
                width: 24.r,
                height: 24.r,
              )
              // const Icon(Icons.chevron_right, color: MITIColor.primary),
            ],
          ),
        )
      ],
    );
  }
}

class KakaoLoginButton extends ConsumerWidget {
  final bool isLogin;

  const KakaoLoginButton({
    super.key,
    required this.isLogin,
  });

  void signInWithKakao(WidgetRef ref, BuildContext context) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      log('isInstalled =${isInstalled}');
      OAuthToken token = isInstalled
          ? await UserApi.instance
              .loginWithKakaoTalk()
              .then((value) => value)
              .catchError((e, _) {
              log('kakao login fail');
            })
          : await UserApi.instance.loginWithKakaoAccount();
      log('token ${token}');
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
      log('token Info = ${tokenInfo}');
      log('access token ${token.accessToken}');
      final KakaoLoginParam param =
          KakaoLoginParam(access_token: token.accessToken);

      final result = await ref
          .read(loginProvider(param: param, type: AuthType.kakao).future);
      // final result = await ref
      //     .read(oauthLoginProvider(param: param, type: AuthType.kakao).future);
      if (context.mounted) {
        if (result is ErrorModel) {
          final String userInfoToken = result.data['userinfo_token'];
          log("userInfoToken = $userInfoToken");
          final storage = ref.read(secureStorageProvider);
          await storage.write(key: "userInfoToken", value: userInfoToken);
          if (context.mounted) {
            AuthError.fromModel(model: result).responseError(
                context, AuthApiType.oauth, ref,
                object: AuthType.kakao);
          }
          throw Exception();
        } else {
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
            SizedBox(width: 20.w),
            SvgPicture.asset(
              'assets/images/logo/kakao_logo.svg',
              width: 24.w,
              height: 20.h,
            ),
            const Spacer(),
            Text(
              '카카오로 3초만에 시작하기',
              style: MITITextStyle.smBold.copyWith(
                color: MITIColor.gray800,
              ),
            ),
            SizedBox(width: 72.5.w),
          ],
        ),
      ),
    );
  }
}

class AppleLoginButton extends ConsumerWidget {
  final bool isLogin;

  const AppleLoginButton({
    super.key,
    required this.isLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        await appleLogin(ref, context);

        // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
        // after they have been validated with Apple (see `Integration` section for more information on how to do this)
      },
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
            color: MITIColor.white, borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          children: [
            SizedBox(width: 27.w),
            SvgPicture.asset(
              'assets/images/logo/apple_logo.svg',
              width: 24.w,
              height: 20.h,
              colorFilter:
                  const ColorFilter.mode(Color(0xFF000000), BlendMode.srcIn),
            ),
            const Spacer(),
            Text(
              'Apple ID로 시작하기',
              style: MITITextStyle.smBold.copyWith(
                color: MITIColor.gray800,
              ),
            ),
            SizedBox(width: 88.5.w),
          ],
        ),
      ),
    );
  }

  Future<void> appleLogin(WidgetRef ref, BuildContext context) async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final param = AppleLoginParam.fromModel(credential: credential);
    final result = await ref
        .read(loginProvider(param: param, type: AuthType.apple).future);

    if (context.mounted) {
      if (result is ErrorModel) {
        final String userInfoToken = result.data['userinfo_token'];
        log("userInfoToken = $userInfoToken");
        final storage = ref.read(secureStorageProvider);
        await storage.write(key: "userInfoToken", value: userInfoToken);
        if (context.mounted) {
          AuthError.fromModel(model: result).responseError(
              context, AuthApiType.oauth, ref,
              object: AuthType.apple);
        }
      } else {
        context.goNamed(CourtMapScreen.routeName);
      }
    }

    // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
    // after they have been validated with Apple (see `Integration` section for more information on how to do this)
  }
}

class HelpComponent extends StatelessWidget {
  const HelpComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {},
              child: Text(
                '고객센터',
                style: MITITextStyle.xxsm.copyWith(
                  color: const Color(0xFF8C8C8C),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              ' | ',
              style: MITITextStyle.xxsm.copyWith(
                color: const Color(0xFF8C8C8C),
              ),
            ),
            SizedBox(width: 16.w),
            InkWell(
              onTap: () {
                context.pushNamed(
                  FindInfoScreen.routeName,
                );
              },
              child: Text(
                'ID / PW를 잊으셨나요?',
                style: MITITextStyle.xxsm.copyWith(
                  color: const Color(0xFF8C8C8C),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}
