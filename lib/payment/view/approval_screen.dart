import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/theme/text_theme.dart';

class PayApprovalScreen extends StatelessWidget {
  static String get routeName => 'KakaoPayApproval';

  const PayApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2F1FF),
      body: Column(
        children: [
          SizedBox(height: 246.h),
          Text(
            '🎉 매치 참여 완료!',
            style: MITITextStyle.pageMainTextStyle.copyWith(
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '아래에서 경기 정보를 확인하세요',
            style: MITITextStyle.pageSubTextStyle.copyWith(
              color: const Color(0xFF333333),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 13.h,
            ),
            child: TextButton(
              onPressed: () => context.goNamed(CourtMapScreen.routeName),
              child: const Text('홈으로 돌아가기'),
            ),
          ),
        ],
      ),
    );
  }
}
