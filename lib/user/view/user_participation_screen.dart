import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/custom_drop_down_button.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/user/provider/user_pagination_provider.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/dispose_sliver_cursor_pagination_list_view.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/provider/cursor_pagination_provider.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../court/view/court_map_screen.dart';
import '../../game/component/game_list_component.dart';
import '../../game/component/skeleton/game_list_skeleton.dart';
import '../../game/model/v2/game/base_game_court_by_date_response.dart';
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
    _scrollController = ScrollController();
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
    final id = ref.read(authProvider)!.id!;
    final gameStatus =
        getStatus(ref.read(dropDownValueProvider(DropButtonType.game)));
    final provider = widget.type == UserGameType.host
        ? userHostingPProvider(PaginationStateParam(path: id))
        : userParticipationPProvider(PaginationStateParam(path: id))
            as AutoDisposeStateNotifierProvider<
                CursorPaginationProvider<Base, DefaultParam,
                    IBaseCursorPaginationRepository<Base, DefaultParam>>,
                BaseModel>;
    ref.read(provider.notifier).paginate(
          path: id,
          forceRefetch: true,
          param: UserGameParam(
            game_status: gameStatus,
          ),
          cursorPaginationParams: const CursorPaginationParam(),
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
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final gameStatus = getStatus(
                  ref.watch(dropDownValueProvider(DropButtonType.game)));
              final provider = widget.type == UserGameType.host
                  ? userHostingPProvider(PaginationStateParam(path: id))
                      as AutoDisposeStateNotifierProvider<
                          CursorPaginationProvider<Base, DefaultParam,
                              IBaseCursorPaginationRepository<Base, DefaultParam>>,
                          BaseModel>
                  : userParticipationPProvider(PaginationStateParam(path: id));
              return SliverPadding(
                padding: EdgeInsets.only(right: 21.w, left: 21.w, bottom: 20.h),
                sliver: DisposeSliverCursorPaginationListView(
                  provider: provider,
                  itemBuilder: (BuildContext context, int index, Base pModel) {
                    final model = pModel as BaseGameCourtByDateResponse;
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


}
