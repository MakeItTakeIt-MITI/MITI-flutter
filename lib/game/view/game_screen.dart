import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_host_list_screen.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/custom_drop_down_button.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/dispose_sliver_pagination_list_view.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../theme/color_theme.dart';
import '../../user/param/user_profile_param.dart';
import '../../user/provider/user_pagination_provider.dart';
import '../component/game_list_component.dart';
import '../model/game_model.dart';

class GameScreen extends ConsumerStatefulWidget {
  static String get routeName => 'game';

  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  final items = [
    '모집 중',
    '모집 완료',
    '경기 취소',
    '경기 완료',
    '전체',
  ];

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
    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () => context.pushNamed(GameCreateScreen.routeName),
        child: Container(
          padding:
              EdgeInsets.only(left: 12.w, right: 16.w, top: 10.h, bottom: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            color: MITIColor.primary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add,
                color: MITIColor.gray800,
              ),
              Text(
                '경기 생성',
                style: MITITextStyle.md.copyWith(
                  color: MITIColor.gray800,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: NestedScrollView(
            // controller: controller[1],
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                // DefaultAppBar(isSliver: true, title: '타이틀',),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(TabBar(
                    indicatorWeight: 1.w,
                    unselectedLabelColor: MITIColor.gray500,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: MITITextStyle.xxsm,
                    controller: tabController,
                    dividerColor: MITIColor.gray500,
                    onTap: (idx) {
                      tabController.animateTo(idx);
                    },
                    tabs: [
                      Tab(
                        child: Text('호스트로 참여한 경기'),
                        height: 44.h,
                      ),
                      Tab(
                        child: Text('게스트로 참여한 경기'),
                        height: 44.h,
                      ),
                    ],
                  )),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(controller: tabController, children: const [
              GameHostScreen(
                type: UserGameType.host,
              ),
              GameHostScreen(
                type: UserGameType.participation,
              )
            ])),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => 44.h;

  @override
  double get maxExtent => 44.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
