import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:miti/auth/error/auth_error.dart';
import 'package:miti/auth/provider/widget/find_info_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../../common/component/default_appbar.dart';
import '../../../user/param/user_profile_param.dart';
import '../../provider/widget/sign_up_form_provider.dart';
import '../signup/signup_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final int userId;
  final String password_update_token;

  static String get routeName => 'resetPassword';

  const ResetPasswordScreen(
      {super.key, required this.password_update_token, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(
        title: '회원 정보 찾기',
        hasBorder: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            Text(
              '비밀번호를 입력해주세요.',
              style: MITITextStyle.xxl140.copyWith(
                color: MITIColor.white,
              ),
            ),
            const PasswordForm(),
            const Spacer(),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final progressModel = ref.watch(progressProvider);
                final validNext = progressModel.validNext;
                return TextButton(
                    onPressed: () async {
                      final newPassword = ref.read(signUpFormProvider).password;
                      final checkPassword =
                          ref.read(signUpFormProvider).checkPassword;
                      final param = UserPasswordParam(
                          new_password_check: checkPassword,
                          new_password: newPassword,
                          password_update_token: password_update_token);
                      final result = await ref
                          .read(updatePasswordProvider(userId, param).future);
                      if (context.mounted) {
                        if (result is ErrorModel) {
                        } else {
                          context.goNamed(CompleteRestPasswordScreen.routeName);
                        }
                      }

                      // final reissueToken =
                      //     await ref.read(reissueForPasswordProvider.future);
                      // if (context.mounted) {
                      //   if (reissueToken is ErrorModel) {
                      //     AuthError.fromModel(model: reissueToken)
                      //         .responseError(
                      //             context, AuthApiType.tokenForPassword, ref);
                      //   } else {
                      //
                      //     if (result is ErrorModel) {
                      //       AuthError.fromModel(model: result).responseError(
                      //           context, AuthApiType.resetPassword, ref);
                      //     } else {
                      //       context
                      //           .goNamed(CompleteRestPasswordScreen.routeName);
                      //     }
                      //   }
                      // }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor:
                            validNext ? MITIColor.primary : MITIColor.gray500),
                    child: Text(
                      '비밀번호 재설정',
                      style: MITITextStyle.mdBold.copyWith(
                        color: validNext ? MITIColor.gray800 : MITIColor.gray50,
                      ),
                    ));
              },
            ),
            SizedBox(height: 41.h),
          ],
        ),
      ),
    );
  }
}

class CompleteRestPasswordScreen extends StatelessWidget {
  static String get routeName => 'completeResetPassword';

  const CompleteRestPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(
        title: '회원 정보 찾기',
        hasBorder: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 200.h),
            Lottie.asset(
              'assets/lottie/success2.json',
              width: 100.r,
              height: 100.r,
              fit: BoxFit.fill,
              repeat: false,
            ),
            SizedBox(
              height: 20.h,
            ),
            Text(
              '비밀번호 설정 완료',
              style: MITITextStyle.xxl140.copyWith(
                color: MITIColor.white,
              ),
            ),
            SizedBox(height: 40.h),
            Text(
              '변경된 비밀번호로 로그인하시길 바랍니다.',
              style: MITITextStyle.sm150.copyWith(
                color: MITIColor.gray300,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.goNamed(LoginScreen.routeName),
              child: const Text('로그인 하러 가기'),
            ),
            SizedBox(height: 41.h),
          ],
        ),
      ),
    );
  }
}
