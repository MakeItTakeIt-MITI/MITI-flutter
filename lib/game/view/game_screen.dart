import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/provider/widget/game_status_filter_provider.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_participation_screen.dart';

import '../../common/component/custom_bottom_sheet.dart';
import '../../common/component/fab_button.dart';
import '../../common/component/sliver_delegate.dart';
import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';
import '../../theme/color_theme.dart';
import '../../user/param/user_profile_param.dart';
import '../../user/provider/user_host_pagination_provider.dart';
import '../../user/provider/user_participation_pagination_provider.dart';
import '../../util/util.dart';
import '../component/game_list_filter_status_bar.dart';

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
    '전체',
    '모집 중',
    '모집 완료',
    '경기 취소',
    '경기 완료',
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      vsync: this,
    )..addListener(() {
        ref.read(gameStatusFilterProvider.notifier).selectAll();
        removeFocus();
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(gameStatusFilterProvider, (previous, next) {
        log('next = ${next}');
        _handleFilterChange(next);
      });
    });
  }

  void _handleFilterChange(List<GameStatusType> statuses) {
    final param = UserGameParam(game_status: statuses);
    const cursorParam = CursorPaginationParam();
    log("message");
    if (tabController.index == 1) {
      ref
          .read(
              userHostingPaginationProvider(cursorParam: cursorParam).notifier)
          .paginate(
              forceRefetch: true,
              param: param,
              cursorPaginationParams: cursorParam);
    } else {
      ref
          .read(userParticipationPaginationProvider(cursorParam: cursorParam)
              .notifier)
          .paginate(
              forceRefetch: true,
              param: param,
              cursorPaginationParams: cursorParam);
    }
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

  GameStatusType? _getStatusFromString(String displayName) {
    switch (displayName.replaceAll(" ", "")) {
      case '모집중':
        return GameStatusType.open;
      case '모집완료':
        return GameStatusType.closed;
      case '경기취소':
        return GameStatusType.canceled;
      case '경기완료':
        return GameStatusType.completed;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FABButton(
        onTap: () => context.pushNamed(GameCreateScreen.routeName),
        text: '경기 생성',
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
                    unselectedLabelColor: V2MITIColor.gray6,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: V2MITITextStyle.tinyMediumNormal,
                    controller: tabController,
                    dividerColor: V2MITIColor.gray6,
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
                    final selectedStatuses =
                        ref.watch(gameStatusFilterProvider);
                    final isAllSelected =
                        selectedStatuses.length == GameStatusType.values.length;

                    return SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverAppBarDelegate(
                        height: 58.h,
                        child: GameListFilterStatusBar(
                          onFilterTap: () {
                            // 현재 선택된 상태를 임시 상태로 복사
                            List<GameStatusType> tempSelectedStatuses =
                                List.from(selectedStatuses);

                            CustomBottomSheet.showWidgetContent(
                                context: context,
                                content: StatefulBuilder(
                                    builder: (context, setBottomSheetState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (_, idx) {
                                          bool isSelected;

                                          // ✅ 선택 상태 판단 로직 개선
                                          if (idx == 0) {
                                            // '전체'
                                            isSelected = tempSelectedStatuses
                                                    .length ==
                                                GameStatusType.values.length;
                                          } else {
                                            // 개별 항목
                                            isSelected = _containStatus(
                                                tempSelectedStatuses,
                                                items[idx]);
                                          }

                                          return GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () {
                                              setBottomSheetState(() {
                                                if (idx == 0) {
                                                  // '전체' 클릭
                                                  // ✅ 전체 선택 시 모든 항목 선택
                                                  tempSelectedStatuses =
                                                      GameStatusType.values
                                                          .toList();
                                                } else {
                                                  // 개별 항목 클릭
                                                  final status =
                                                      _getStatusFromString(
                                                          items[idx]);
                                                  if (status != null) {
                                                    // ✅ 현재 전체가 선택되어 있는지 확인
                                                    bool
                                                        isCurrentlyAllSelected =
                                                        tempSelectedStatuses
                                                                .length ==
                                                            GameStatusType
                                                                .values.length;

                                                    if (isCurrentlyAllSelected) {
                                                      // ✅ 전체 선택 상태에서 개별 항목 클릭 시 → 해당 항목만 제거
                                                      tempSelectedStatuses =
                                                          GameStatusType.values
                                                              .where(
                                                                  (element) =>
                                                                      element !=
                                                                      status)
                                                              .toList();
                                                    } else {
                                                      // ✅ 일반적인 토글 로직
                                                      if (tempSelectedStatuses
                                                          .contains(status)) {
                                                        tempSelectedStatuses
                                                            .remove(status);
                                                      } else {
                                                        tempSelectedStatuses
                                                            .add(status);

                                                        // ✅ 모든 항목이 선택되면 자동으로 '전체' 상태가 됨
                                                        if (tempSelectedStatuses
                                                                .length ==
                                                            GameStatusType
                                                                .values
                                                                .length) {
                                                          // 이미 모든 항목이 선택되어 있음 (자동으로 '전체' 표시됨)
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              });
                                            },
                                            child: SizedBox(
                                              height: 48.h,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    items[idx],
                                                    style: V2MITITextStyle
                                                        .regularMediumNormal
                                                        .copyWith(
                                                            color: isSelected
                                                                ? V2MITIColor
                                                                    .primary5
                                                                : V2MITIColor
                                                                    .white),
                                                  ),
                                                  SvgPicture.asset(
                                                    AssetUtil.getAssetPath(
                                                        type: AssetType.icon,
                                                        name: "active_check"),
                                                    height: 16.r,
                                                    width: 16.r,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                      isSelected
                                                          ? V2MITIColor.primary5
                                                          : V2MITIColor.white,
                                                      BlendMode.srcIn,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (_, idx) => Divider(
                                            height: 16.h,
                                            color: V2MITIColor.gray10),
                                        itemCount: items.length,
                                      ),
                                    ],
                                  );
                                }),
                                onPressed: () {
                                  ref
                                      .read(gameStatusFilterProvider.notifier)
                                      .setSelectedStatuses(
                                          tempSelectedStatuses);
                                  context.pop();
                                },
                                title: '경기 상태',
                                buttonText: '설정하기',
                                useRootNavigator: true,
                                hasPop: true);
                          },
                          onDeleted: (GameStatusType status) {
                            ref
                                .read(gameStatusFilterProvider.notifier)
                                .toggleStatus(status);
                          },
                          items: selectedStatuses,
                        ),
                        // _GameFilterComponent(
                        //   type: type,
                        // )
                      ),
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

  _containStatus(List<GameStatusType> origin, String target) {
    return origin.any((e) => e.displayName == target.replaceAll(" ", ""));
  }
}
