import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_host_list_screen.dart';

import '../../common/component/default_appbar.dart';
import '../../theme/color_theme.dart';

class GameScreen extends StatefulWidget {
  static String get routeName => 'game';

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      vsync: this,
    )..addListener(() {
        removeFocus();
      });
  }

  void removeFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void dispose() {
    tabController.removeListener(() {
      removeFocus();
    });
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        MITITextStyle.menuChoiceStyle.copyWith(color: Colors.black);
    return NestedScrollView(
      // controller: controller[1],
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          // SliverToBoxAdapter(
          //   child: TabBar(
          //     indicatorWeight: 1.w,
          //     unselectedLabelColor: MITIColor.gray500,
          //     indicatorSize: TabBarIndicatorSize.tab,
          //     labelStyle: MITITextStyle.xxsm,
          //     controller: tabController,
          //     dividerColor: MITIColor.gray500,
          //     onTap: (idx) {
          //       tabController.animateTo(idx);
          //     },
          //     tabs: const [
          //       Tab(child: Text('호스트로 참여한 경기')),
          //       Tab(child: Text('게스트로 참여한 경기')),
          //     ],
          //   ),
          // )
        ];
      },
      body: CustomScrollView(
        slivers: [
          // SliverToBoxAdapter(
          //   child: TabBarView(
          //     controller: tabController,
          //     children: [
          //       Container(),
          //       Container(),
          //     ],
          //   ),
          // ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      const extra = UserGameType.participation;
                      final Map<String, String> queryParameters = {
                        'bottomIdx': '1'
                      };
                      context.pushNamed(
                        GameHostScreen.routeName,
                        extra: extra,
                        queryParameters: queryParameters,
                      );
                    },
                    child: Text(
                      '나의 참여 경기',
                      style: textStyle,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  InkWell(
                    onTap: () {
                      const extra = UserGameType.host;
                      final Map<String, String> queryParameters = {
                        'bottomIdx': '1'
                      };
                      context.pushNamed(
                        GameHostScreen.routeName,
                        extra: extra,
                        queryParameters: queryParameters,
                      );
                    },
                    child: Text(
                      '나의 호스팅 경기',
                      style: textStyle,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  InkWell(
                    onTap: () {
                      final Map<String, String> queryParameters = {
                        'bottomIdx': '1'
                      };
                      context.pushNamed(
                        GameCreateScreen.routeName,
                        queryParameters: queryParameters,
                      );
                    },
                    child: Text(
                      '경기 생성하기',
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
