import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/error/auth_error.dart';
import 'package:miti/auth/provider/widget/find_info_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/model/default_model.dart';

import '../../../common/component/default_appbar.dart';
import '../../provider/widget/sign_up_form_provider.dart';
import '../signup/signup_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  static String get routeName => 'resetPassword';

  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(
        title: '회원 정보 찾기',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 38.h),
            Text(
              '비밀번호를 입력해주세요.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.25,
              ),
            ),
            SizedBox(height: 25.h),
            const PasswordForm(),
            const Spacer(),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final progressModel = ref.watch(progressProvider);
                final validNext = progressModel.validNext;
                return TextButton(
                    onPressed: () async {
                      final result =
                          await ref.read(resetPasswordProvider.future);
                      if (context.mounted) {
                        if (result is ErrorModel) {
                          AuthError.fromModel(model: result)
                              .responseError(context, AuthApiType.login, ref);
                        } else {
                          context.goNamed(CompleteRestPasswordScreen.routeName);
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: validNext
                            ? const Color(0xFF4065F6)
                            : const Color(0xFFE8E8E8)),
                    child: Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: validNext
                              ? Colors.white
                              : const Color(0xFF969696)),
                    ));
              },
            ),
            SizedBox(height: 11.h),
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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 208.h),
            Text(
              '비밀번호 설정 완료',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.25,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '변경된 비밀번호로 로그인하시길 바랍니다.',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.25,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.goNamed(LoginScreen.routeName),
              child: Text(
                '로그인하기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(height: 11.h),
          ],
        ),
      ),
    );
  }
}
