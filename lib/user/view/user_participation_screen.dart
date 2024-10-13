import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/custom_drop_down_button.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/user/provider/user_pagination_provider.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/provider/pagination_provider.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../game/component/game_list_component.dart';
import '../../game/component/skeleton/game_list_skeleton.dart';
import '../../game/model/game_model.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../param/user_profile_param.dart';

class UserParticipationScreen extends ConsumerStatefulWidget {
  static String get routeName => 'userParticipation';
  final UserGameType type;

  const UserParticipationScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<UserParticipationScreen> createState() =>
      _GameHostScreenState();
}

class _GameHostScreenState extends ConsumerState<UserParticipationScreen> {
  final items = [
    '전체',
    '모집 중',
    '모집 완료',
    '경기 취소',
    '경기 완료',
  ];
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GameStatus? getStatus(String? value) {
    switch (value) {
      case '모집 중':
        return GameStatus.open;
      case '모집 완료':
        return GameStatus.closed;
      case '경기 취소':
        return GameStatus.canceled;
      case '경기 완료':
        return GameStatus.completed;
      default:
        return null;
    }
  }

  Future<void> refresh() async {
    final id = ref.read(authProvider)!.id!;
    final gameStatus =
        getStatus(ref.read(dropDownValueProvider(DropButtonType.game)));
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

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(authProvider)!.id!;

    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 21.w, right: 21.w, top: 20.h),
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
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final gameStatus = getStatus(ref
                          .watch(dropDownValueProvider(DropButtonType.game)));
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.h),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MITIColor.gray100,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
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
                                            style:
                                                MITITextStyle.mdBold.copyWith(
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      i,
                                                      style: MITITextStyle
                                                          .smSemiBold
                                                          .copyWith(
                                                              color: selectStatus ==
                                                                      i
                                                                  ? MITIColor
                                                                      .primary
                                                                  : MITIColor
                                                                      .gray100),
                                                    ),
                                                    if (selectStatus == i)
                                                      SvgPicture.asset(
                                                        AssetUtil.getAssetPath(
                                                            type:
                                                                AssetType.icon,
                                                            name:
                                                                "active_check"),
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
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final gameStatus = getStatus(
                  ref.watch(dropDownValueProvider(DropButtonType.game)));
              final provider = widget.type == UserGameType.host
                  ? userHostingPProvider(PaginationStateParam(path: id))
                      as AutoDisposeStateNotifierProvider<
                          PaginationProvider<Base, DefaultParam,
                              IBasePaginationRepository<Base, DefaultParam>>,
                          BaseModel>
                  : userParticipationPProvider(PaginationStateParam(path: id));
              return SliverPadding(
                padding: EdgeInsets.only(right: 21.w, left: 21.w, bottom: 20.h),
                sliver: DisposeSliverPaginationListView(
                  provider: provider,
                  itemBuilder: (BuildContext context, int index, Base pModel) {
                    final model = pModel as GameListByDateModel;
                    return GameCardByDate.fromModel(
                      model: model,
                    );
                  },
                  skeleton: const GameListSkeleton(),
                  param: UserGameParam(
                    game_status: gameStatus,
                  ),
                  controller: _scrollController,
                  emptyWidget: getEmptyWidget(widget.type),
                  separateSize: 0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getEmptyWidget(UserGameType type) {
    final title = type == UserGameType.host
        ? '아직 생성한 경기가 없습니다.'
        : '참여가 예정된 경기나\n참여한 경기 내역이 없습니다.';
    final desc = type == UserGameType.host
        ? '원하는 경기를 생성하고 게스트를 모집해보세요!'
        : '새로운 경기를 찾아보거나 직접 경기를 생성해보세요!';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: MITITextStyle.pageMainTextStyle
              .copyWith(color: MITIColor.gray100),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        Text(
          desc,
          style:
              MITITextStyle.pageSubTextStyle.copyWith(color: MITIColor.gray100),
        )
      ],
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
