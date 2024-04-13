import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_info_screen.dart';

import '../../../common/component/default_appbar.dart';

class PhoneAuthScreen extends ConsumerWidget {
  static String get routeName => 'phone';

  const PhoneAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Expanded(
                child: Column(
              children: [
                SizedBox(height: 220.h),
                Text(
                  '❗사용자 인증 미완료',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.25.sp,
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  '휴대전화번호를 통해 사용자 인증을\n완료하시길 바랍니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    letterSpacing: -0.25.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF333333),
                  ),
                )
              ],
            )),
            TextButton(
              onPressed: () => context.pushNamed(PhoneAuthInfoScreen.routeName),
              child: Text(
                '인증하기',
                style: TextStyle(
                  fontSize: 14.sp,
                  letterSpacing: -0.25.sp,
                  fontWeight: FontWeight.bold,
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
}


