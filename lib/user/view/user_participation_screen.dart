import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_drop_down_button.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/user/provider/user_host_pagination_provider.dart';
import 'package:miti/user/provider/user_participation_pagination_provider.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../common/error/view/error_screen.dart';
import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../court/view/court_map_screen.dart';
import '../../game/component/game_list_component.dart';
import '../../game/model/v2/game/base_game_response.dart';
import '../../theme/text_theme.dart';
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
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((s) {
      ref
          .read(scrollControllerProvider.notifier)
          .update((s) => _scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  Future<void> refresh() async {
    final gameStatus =
        getStatus(ref.read(dropDownValueProvider(DropButtonType.game)));
    if (widget.type == UserGameType.host) {
      ref
          .read(userHostingPaginationProvider(
                  param: UserGameParam(game_status: gameStatus),
                  cursorParam: const CursorPaginationParam())
              .notifier)
          .paginate(
            forceRefetch: true,
            param: UserGameParam(
              game_status: gameStatus,
            ),
            cursorPaginationParams: const CursorPaginationParam(),
          );
    } else {
      ref
          .read(userParticipationPaginationProvider(
                  param: UserGameParam(game_status: gameStatus),
                  cursorParam: const CursorPaginationParam())
              .notifier)
          .paginate(
            forceRefetch: true,
            param: UserGameParam(
              game_status: gameStatus,
            ),
            cursorPaginationParams: const CursorPaginationParam(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final gameStatus = getStatus(
                  ref.watch(dropDownValueProvider(DropButtonType.game)));

              final state = widget.type == UserGameType.host
                  ? ref.watch(userHostingPaginationProvider(
                      param: UserGameParam(game_status: gameStatus),
                      cursorParam: const CursorPaginationParam()))
                  : ref.watch(userParticipationPaginationProvider(
                      param: UserGameParam(game_status: gameStatus),
                      cursorParam: const CursorPaginationParam()));

              // 완전 처음 로딩일때
              if (state is LoadingModel) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ); // todo 스켈레톤 일반화
              }

              if (state is ErrorModel) {
                WidgetsBinding.instance.addPostFrameCallback((s) {
                  context.pushReplacementNamed(ErrorScreen.routeName);
                });
              }

              final cp = state as ResponseModel<
                  CursorPaginationModel<List<BaseGameResponse>>>;
              log('state.data!.page_content = ${state.data!.items.length}');
              if (state.data!.items.isEmpty) {
                return getEmptyWidget(widget.type);
              }

              return SliverPadding(
                padding: EdgeInsets.only(right: 21.w, left: 21.w, bottom: 20.h),
                sliver: SliverList.separated(
                  itemBuilder: (_, index) {
                    if (index == (cp.data!.items.length)) {
                      if (cp is! ResponseModel<
                          CursorPaginationModelFetchingMore>) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {});
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Center(
                          child: cp is ResponseModel<
                                  CursorPaginationModelFetchingMore>
                              ? const CircularProgressIndicator()
                              : Container(),
                        ),
                      );
                    }

                    final pItem = cp.data!.items[index];

                    return GameCardByDate.fromModel(
                      model: pItem,
                    );
                  },
                  itemCount: cp.data!.items.length + 1, separatorBuilder: (BuildContext context, int index) {
                    return  SizedBox(height: 32.h);
                },
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
    return SliverFillRemaining(
      child: Column(
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
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 300) {
      final gameStatus =
          getStatus(ref.read(dropDownValueProvider(DropButtonType.game)));
      if (widget.type == UserGameType.host) {
        log("더 불러오기!!");
        ref
            .read(userHostingPaginationProvider(
                    param: UserGameParam(game_status: gameStatus),
                    cursorParam: const CursorPaginationParam())
                .notifier)
            .paginate(
              fetchMore: true,
              param: UserGameParam(
                game_status: gameStatus,
              ),
              cursorPaginationParams: const CursorPaginationParam(),
            );
      } else {
        ref
            .read(userParticipationPaginationProvider(
                    param: UserGameParam(game_status: gameStatus),
                    cursorParam: const CursorPaginationParam())
                .notifier)
            .paginate(
              fetchMore: true,
              param: UserGameParam(
                game_status: gameStatus,
              ),
              cursorPaginationParams: const CursorPaginationParam(),
            );
      }
      //   // 스크롤이 끝에 도달했을 때 새로운 항목 로드
    }
  }
}
