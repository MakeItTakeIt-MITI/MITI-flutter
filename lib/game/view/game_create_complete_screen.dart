import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/theme/text_theme.dart';

class GameCreateCompleteScreen extends StatelessWidget {
  final int gameId;
  final int bottomIdx;

  static String get routeName => 'gameCreateComplete';

  const GameCreateCompleteScreen({super.key, required this.gameId, required this.bottomIdx});

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
            '🎉 경기 생성 완료!',
            style: MITITextStyle.pageMainTextStyle.copyWith(
              color: Colors.black,
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            '아래 버튼을 통해 경기 정보를 확인하세요.',
            style: MITITextStyle.pageSubTextStyle.copyWith(
              color: const Color(0xFF333333),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
            child: SizedBox(
              height: 48.h,
              child: TextButton(
                onPressed: () {
                  Map<String, String> pathParameters = {
                    'gameId': gameId.toString()
                  };
                  final Map<String, String> queryParameters = {
                    'bottomIdx': bottomIdx.toString()
                  };
                  context.goNamed(
                    GameDetailScreen.routeName,
                    pathParameters: pathParameters,
                    queryParameters: queryParameters,
                  );
                },
                style: TextButton.styleFrom(
                    fixedSize: Size(double.infinity, 48.h)),
                child: const Text('경기 정보 조회'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
