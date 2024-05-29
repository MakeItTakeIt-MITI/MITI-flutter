import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_host_list_screen.dart';

import '../../common/component/default_appbar.dart';
import '../../common/provider/scroll_provider.dart';

class GameScreen extends ConsumerWidget {
  static String get routeName => 'game';

  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(pageScrollControllerProvider);
    final textStyle =
        MITITextStyle.menuChoiceStyle.copyWith(color: Colors.black);
    return NestedScrollView(
      // controller: controller[1],
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
