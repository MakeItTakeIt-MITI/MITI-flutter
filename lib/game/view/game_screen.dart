import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_participation_screen.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/custom_drop_down_button.dart';
import '../../common/component/sliver_delegate.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../theme/color_theme.dart';
import '../../user/param/user_profile_param.dart';
import '../../user/provider/user_pagination_provider.dart';
import '../../util/util.dart';

final currentGameTypeProvider =
    StateProvider.autoDispose<UserGameType>((ref) => UserGameType.participation);

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
        ref.read(currentGameTypeProvider.notifier).update((s) =>
            tabController.index == 0
                ? UserGameType.participation
                : UserGameType.host);
        ref
            .read(dropDownValueProvider(DropButtonType.game).notifier)
            .update((s) => null);
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
            physics: const NeverScrollableScrollPhysics(),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                      child: TabBar(
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
                        height: 44.h,
                        child: const Text('게스트 경기'),
                      ),
                      Tab(
                        height: 44.h,
                        child: const Text('호스트 경기'),
                      ),
                    ],
                  )),
                  pinned: true,
                ),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final type = ref.watch(currentGameTypeProvider);
                    return SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverAppBarDelegate(
                          height: 58.h,
                          child: _GameFilterComponent(
                            type: type,
                          )),
                    );
                  },
                ),
              ];
            },
            body: TabBarView(controller: tabController, children: const [
              UserParticipationScreen(
                type: UserGameType.participation,
              ),
              UserParticipationScreen(
                type: UserGameType.host,
              ),
            ])),
      ),
    );
  }
}

class _GameFilterComponent extends ConsumerStatefulWidget {
  final UserGameType type;

  const _GameFilterComponent({super.key, required this.type});

  @override
  ConsumerState<_GameFilterComponent> createState() =>
      _GameFilterComponentState();
}

class _GameFilterComponentState extends ConsumerState<_GameFilterComponent> {
  GameStatusType? getStatus(String? value) {
    switch (value) {
      case '모집 중':
        return GameStatusType.open;
      case '모집 완료':
        return GameStatusType.closed;
      case '경기 취소':
        return GameStatusType.canceled;
      case '경기 완료':
        return GameStatusType.completed;
      default:
        return null;
    }
  }

  final items = [
    '전체',
    '모집 중',
    '모집 완료',
    '경기 취소',
    '경기 완료',
  ];

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(authProvider)!.id!;
    return SizedBox(
      height: 58.h,
      child: Padding(
        padding:
            EdgeInsets.only(left: 21.w, right: 21.w, top: 20.h, bottom: 10.h),
        child: Row(
          children: [
            Text(
              widget.type == UserGameType.host
                  ? '호스트가 되어 게스트를 모집한 경기'
                  : '게스트로 참여한 경기',
              style: MITITextStyle.sm.copyWith(color: MITIColor.gray100),
            ),
            const Spacer(),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final gameStatus = getStatus(
                    ref.watch(dropDownValueProvider(DropButtonType.game)));
                final selectStatus = gameStatus?.displayName ?? '전체';
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        useRootNavigator: true,
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                        ),
                        backgroundColor: MITIColor.gray800,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: MITIColor.gray100,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  width: 60.w,
                                  height: 4.h,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(20.r),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '경기 상태',
                                      style: MITITextStyle.mdBold.copyWith(
                                        color: MITIColor.gray100,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    ...items.map((i) {
                                      return GestureDetector(
                                        onTap: () {
                                          changeDropButton(i, id);
                                          context.pop();
                                        },
                                        child: Container(
                                          height: 60.h,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: MITIColor.gray700,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                i,
                                                style: MITITextStyle.smSemiBold
                                                    .copyWith(
                                                        color: selectStatus == i
                                                            ? MITIColor.primary
                                                            : MITIColor
                                                                .gray100),
                                              ),
                                              if (selectStatus == i)
                                                SvgPicture.asset(
                                                  AssetUtil.getAssetPath(
                                                      type: AssetType.icon,
                                                      name: "active_check"),
                                                  height: 24.r,
                                                  width: 24.r,
                                                )
                                            ],
                                          ),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              )
                            ],
                          );
                        });
                  },
                  child: Container(
                    width: 92.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                      color: MITIColor.gray700,
                    ),
                    padding: EdgeInsets.only(left: 16.w, right: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          gameStatus?.displayName ?? '전체',
                          style: MITITextStyle.xxsmLight
                              .copyWith(color: MITIColor.gray100),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: MITIColor.primary,
                          size: 16.r,
                        )
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void changeDropButton(String? value, int id) {
    ref
        .read(dropDownValueProvider(DropButtonType.game).notifier)
        .update((state) => value);
    final gameStatus = getStatus(value!);
    final provider = widget.type == UserGameType.host
        ? userHostingPProvider(PaginationStateParam(path: id))
        : userParticipationPProvider(PaginationStateParam(path: id))
            as AutoDisposeStateNotifierProvider<
                PaginationProvider<Base, DefaultParam,
                    IBasePaginationRepository<Base, DefaultParam>>,
                BaseModel>;
    ref.read(provider.notifier).paginate(
          path: id,
          forceRefetch: true,
          param: UserGameParam(
            game_status: gameStatus,
          ),
          paginationParams: const PaginationParam(page: 1),
        );
  }
}
