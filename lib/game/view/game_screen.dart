import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/game/view/game_list_screen.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_host_list_screen.dart';

import '../../common/component/default_appbar.dart';

class GameScreen extends StatelessWidget {
  static String get routeName => 'game';

  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16.sp,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25.sp,
    );
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          const DefaultAppBar(
            isSliver: true,
            title: '나의 경기',
          ),
        ];
      },
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      const extra = UserGameType.participation;
                      context.pushNamed(GameHostScreen.routeName, extra: extra);
                    },
                    child: Text(
                      '🏀 나의 참여 경기',
                      style: textStyle,
                    ),
                  ),
                  SizedBox(height: 26.h),
                  InkWell(
                    onTap: () {
                      const extra = UserGameType.host;
                      context.pushNamed(GameHostScreen.routeName, extra: extra);
                    },
                    child: Text(
                      '🏁 나의 호스팅 경기',
                      style: textStyle,
                    ),
                  ),
                  SizedBox(height: 26.h),
                  InkWell(
                    onTap: () => context.pushNamed(GameCreateScreen.routeName),
                    child: Text(
                      '✉️ 경기 생성하기',
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
