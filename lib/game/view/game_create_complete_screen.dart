import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/default_appbar.dart';

class GameCreateCompleteScreen extends StatelessWidget {
  static String get routeName => 'gameCreateComplete';
  const GameCreateCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        backgroundColor: Color(0xFFE2F1FF),
      ),
      backgroundColor: const Color(0xFFE2F1FF),
      body: Column(
        children: [
          SizedBox(height: 248.h),
          Text(
            '🎉 매치 생성 완료!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.sp,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 40 / 24,
              letterSpacing: -0.25.sp,
            ),
          ),
          Text(
            '아래에서 경기 정보를 확인하세요',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 16.sp,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              height: 22 / 16,
              letterSpacing: -0.25.sp,
            ),
          ),
          Spacer(),
          TextButton(onPressed: () {}, child: const Text('생성 경기 정보')),
        ],
      ),
    );
  }
}
