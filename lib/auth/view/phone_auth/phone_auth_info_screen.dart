import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_send_screen.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/dio/response_code.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';

import '../../../common/component/default_appbar.dart';
import '../../../common/model/default_model.dart';
import '../../error/auth_error.dart';
import '../../model/code_model.dart';
import '../../provider/login_provider.dart';

class PhoneAuthInfoScreen extends ConsumerStatefulWidget {
  static String get routeName => 'phoneInfo';

  const PhoneAuthInfoScreen({super.key});

  @override
  ConsumerState<PhoneAuthInfoScreen> createState() =>
      _PhoneAuthInfoScreenState();
}

class _PhoneAuthInfoScreenState extends ConsumerState<PhoneAuthInfoScreen> {
  bool isVisible = false;

  // InteractionDesc? interactionDesc;
  late final List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
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
    // ref.watch(phoneAuthProvider);
    final interactionDesc =
        ref.watch(interactionDescProvider(InteractionType.normal));
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 118.h),
                Text(
                  '로그인 정보 입력',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.25.sp,
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  focusNode: focusNodes[0],
                  textEditingController: emailController,
                  hintText: '이메일을 입력해주세요.',
                  textInputAction: TextInputAction.next,
                  label: '이메일',
                  onNext: () =>
                      FocusScope.of(context).requestFocus(focusNodes[1]),
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
                    ref
                        .read(loginFormProvider.notifier)
                        .updateFormField(email: val);
                    log(ref.read(loginFormProvider).email);
                  },
                ),
                SizedBox(height: 16.h),
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
                  onNext: () async {
                    await requestSMS(context);
                  },
                  interactionDesc: interactionDesc,
                ),
              ],
            )),
            TextButton(
              onPressed: () async {
                await requestSMS(context);
              },
              child: Text(
                '인증 메세지 전송',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.25.sp,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
            SizedBox(height: 19.h),
          ],
        ),
      ),
    );
  }

  Future<void> requestSMS(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    // final result =
    //     await ref.read(requestSMSProvider(type: PhoneAuthType.login).future);
    // if (result is ResponseModel<RequestCodeModel> && context.mounted) {
    //   context.pushNamed(PhoneAuthSendScreen.routeName);
    // } else {
    //   result as ErrorModel;
    //   if (context.mounted) {
    //     AuthError.fromModel(model: result)
    //         .responseError(context, AuthApiType.request_code, ref);
    //   }
      // if (result.status_code == BadRequest) {
      //   // todo 인증 완료 사용자
      // } else if (result.status_code == UnAuthorized) {
      //   setState(() {
      //     interactionDesc = InteractionDesc(
      //       isSuccess: false,
      //       desc: "일치하는 사용자 정보가 존재하지 않습니다.",
      //     );
      //   });
      //   // todo 사용자 정보 불일치
      // }
    // }
  }
}
