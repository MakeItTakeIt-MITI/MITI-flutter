import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/custom_drop_down_button.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/user/provider/user_pagination_provider.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/provider/pagination_provider.dart';
import '../../common/provider/scroll_provider.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../game/component/game_list_component.dart';
import '../../game/model/game_model.dart';
import '../../theme/text_theme.dart';
import '../param/user_profile_param.dart';
import '../repository/user_repository.dart';

class GameHostScreen extends ConsumerStatefulWidget {
  static String get routeName => 'host';
  final UserGameType type;

  const GameHostScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<GameHostScreen> createState() => _GameHostScreenState();
}

class _GameHostScreenState extends ConsumerState<GameHostScreen> {
  final items = [
    '모집중',
    '모집 완료',
    '경기 취소',
    '경기 완료',
    '전체 보기',
  ];

  GameStatus? getStatus(String? value) {
    switch (value) {
      case '모집중':
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
    final gameStatus = getStatus(ref.read(dropDownValueProvider));
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
    final controller = ref.watch(pageScrollControllerProvider);
    final id = ref.watch(authProvider)!.id!;

    return NestedScrollView(
      controller: controller[1],
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          DefaultAppBar(
            title: widget.type == UserGameType.host ? '나의 호스팅 경기' : '나의 참여 경기',
            isSliver: true,
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(right: 12.w, top: 12.h),
                child: Row(
                  children: [
                    const Spacer(),
                    CustomDropDownButton(
                      initValue: '전체 보기',
                      onChanged: (value) {
                        changeDropButton(value, id);
                      },
                      items: items,
                    )
                  ],
                ),
              ),
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final gameStatus = getStatus(ref.watch(dropDownValueProvider));
                final provider = widget.type == UserGameType.host
                    ? userHostingPProvider(PaginationStateParam(path: id))
                        as AutoDisposeStateNotifierProvider<
                            PaginationProvider<Base, DefaultParam,
                                IBasePaginationRepository<Base, DefaultParam>>,
                            BaseModel>
                    : userParticipationPProvider(
                        PaginationStateParam(path: id));
                return SliverPadding(
                  padding:
                      EdgeInsets.only(right: 12.w, left: 12.w, bottom: 12.h),
                  sliver: DisposeSliverPaginationListView(
                    provider: provider,
                    itemBuilder:
                        (BuildContext context, int index, Base pModel) {
                      final model = pModel as GameListByDateModel;
                      return GameCardByDate.fromModel(
                        model: model,
                      );
                    },
                    skeleton: Container(),
                    param: UserGameParam(
                      game_status: gameStatus,
                    ),
                    controller: controller[1],
                    emptyWidget: getEmptyWidget(widget.type),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getEmptyWidget(UserGameType type) {
    final title = type == UserGameType.host ? '호스팅' : '참여한';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$title 경기가 없습니다.',
          style: MITITextStyle.pageMainTextStyle,
        ),
        SizedBox(height: 20.h),
        Text(
          '경기 생성을 통해 경기를 모집해보세요!',
          style: MITITextStyle.pageSubTextStyle,
        )
      ],
    );
  }

  void changeDropButton(String? value, int id) {
    ref.read(dropDownValueProvider.notifier).update((state) => value);
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
