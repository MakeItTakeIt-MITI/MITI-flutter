import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/error/auth_error.dart';
import 'package:miti/auth/provider/login_provider.dart' hide PhoneAuthType;
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';

import '../../../common/component/custom_text_form_field.dart';
import '../../../common/component/default_appbar.dart';
import '../../../common/provider/form_util_provider.dart';
import '../../model/find_info_model.dart';

class PhoneAuthSendScreen extends ConsumerStatefulWidget {
  static String get routeName => 'phoneSend';

  const PhoneAuthSendScreen({super.key});

  @override
  ConsumerState<PhoneAuthSendScreen> createState() =>
      _PhoneAuthSendScreenState();
}

class _PhoneAuthSendScreenState extends ConsumerState<PhoneAuthSendScreen> {
  @override
  Widget build(BuildContext context) {
    // final code = ref.watch(phoneAuthProvider).code;

    final valid =true;// code.length == 6;
    final interactionDesc =
        ref.watch(codeDescProvider(PhoneAuthType.find_email));
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
                SizedBox(height: 132.h),
                Text(
                  "인증번호 입력",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.25.sp,
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '회원가입시 입력한 번호로 인증번호를 발송했어요.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    letterSpacing: -0.25.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1C1C1C),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomTextFormField(
                  hintText: '인증번호를 입력해주세요.',
                  label: '',
                  onNext: () {
                    sendSMS(context);
                  },
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  // onChanged: (val) {
                  //   ref.read(phoneAuthProvider.notifier).update(code: val);
                  //   if (val.length == 6) {
                  //     sendSMS(context);
                  //   }
                  // },
                  interactionDesc: interactionDesc,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                )
              ],
            )),
            TextButton(
              onPressed: () async {
                sendSMS(context);
              },
              style: TextButton.styleFrom(
                  backgroundColor: valid
                      ? const Color(0xFF4065F6)
                      : const Color(0xFFE8E8E8)),
              child: Text(
                '인증하기',
                style: TextStyle(
                    fontSize: 14.sp,
                    letterSpacing: -0.25.sp,
                    fontWeight: FontWeight.bold,
                    color: valid ? Colors.white : const Color(0xFF969696)),
              ),
            ),
            SizedBox(height: 19.h),
          ],
        ),
      ),
    );
  }

  void sendSMS(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final result = await ref.read(sendSMSProvider.future);
    if (result is ErrorModel) {
      if (context.mounted) {
        AuthError.fromModel(model: result).responseError(
            context, AuthApiType.send_code, ref,
            object: FindInfoType.email);
      }
    } else {
      if (context.mounted) {
        context.goNamed(PhoneAuthSuccess.routeName);
      }
    }
  }
}

class PhoneAuthSuccess extends StatelessWidget {
  static String get routeName => 'phoneAuthSuccess';

  const PhoneAuthSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE2F1FF),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 245.h),
            Text(
              '🎉 사용자 인증 완료!',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.25.sp,
                color: const Color(0xFF000000),
              ),
            ),
            Text(
              '로그인을 완료하고 MITI를 사용해보세요.',
              style: TextStyle(
                fontSize: 16.sp,
                letterSpacing: -0.25.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF333333),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.goNamed(LoginScreen.routeName),
              child: Text(
                '로그인하기',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: -0.25.sp,
                ),
              ),
            ),
            SizedBox(height: 52.h),
          ],
        ),
      ),
    );
  }
}
