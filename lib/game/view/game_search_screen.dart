import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/custom_drop_down_button.dart';
import '../../common/component/dispose_sliver_pagination_list_view.dart';
import '../../common/component/sliver_delegate.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../court/model/v2/court_map_response.dart';
import '../../court/view/court_map_screen.dart';
import '../../court/view/court_search_screen.dart';
import '../../theme/color_theme.dart';
import '../../util/util.dart';
import '../component/skeleton/game_search_skeleton.dart';
import '../model/v2/game/game_with_court_map_response.dart';
import '../provider/game_pagination_provider.dart';
import '../provider/widget/game_search_provider.dart';
import 'game_detail_screen.dart';

class GameSearchScreen extends ConsumerStatefulWidget {
  static String get routeName => 'gameSearch';

  const GameSearchScreen({super.key});

  @override
  ConsumerState<GameSearchScreen> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends ConsumerState<GameSearchScreen> {
  late final ScrollController controller;
  final SliverOverlapAbsorberHandle _firstHandle =
      SliverOverlapAbsorberHandle();
  final SliverOverlapAbsorberHandle _secondHandle =
      SliverOverlapAbsorberHandle();

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    // WidgetsBinding.instance.addPostFrameCallback((s) {
    //   ref.read(scrollControllerProvider.notifier).update((s) => controller);
    // });
  }

  Future<void> refresh() async {
    final form = ref.read(gameSearchProvider);
    ref.read(gamePageProvider(PaginationStateParam()).notifier).paginate(
        paginationParams: const PaginationParam(page: 1),
        param: form,
        forceRefetch: true);
  }

  @override
  void dispose() {
    _firstHandle.dispose();
    _secondHandle.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomButton(
        button: TextButton(
            onPressed: () {
              context.pushNamed(GameCreateScreen.routeName);
            },
            child: const Text("경기 생성하기")),
        hasBorder: false,
      ),
      body: SafeArea(
        child: NestedScrollView(
            physics: const NeverScrollableScrollPhysics(),
            headerSliverBuilder:
                ((BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: _firstHandle,
                  sliver: const DefaultAppBar(
                    isSliver: true,
                    title: '경기 목록',
                    hasBorder: false,
                  ),
                ),
                SliverOverlapAbsorber(
                  handle: _secondHandle,
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverAppBarDelegate(
                      height: 58.h,
                      child: Container(
                          color: MITIColor.gray800,
                          height: 58.h,
                          child: SearchComponent(
                            selectRegion: selectRegion,
                            onChanged: searchGame,
                            placeholder: '경기 제목을 입력해주세요.',
                          )),
                    ),
                  ),
                ),
              ];
            }),
            body: Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: 58.h + 48.h,
                  ),
                  child: RefreshIndicator(
                    onRefresh: refresh,
                    child: CustomScrollView(
                      controller: controller,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          sliver: SliverMainAxisGroup(slivers: [
                            Consumer(
                              builder: (BuildContext context, WidgetRef ref,
                                  Widget? child) {
                                final form = ref.watch(gameSearchProvider);

                                return DisposeSliverPaginationListView(
                                  provider:
                                      gamePageProvider(PaginationStateParam()),
                                  itemBuilder: (BuildContext context, int index,
                                      Base model) {
                                    model as GameWithCourtMapResponse;
                                    return _GameSearchCard.fromModel(
                                      model: model,
                                      onTap: () {
                                        onTap(model, context);
                                      },
                                    );
                                  },
                                  param: form,
                                  skeleton: const GameSearchSkeleton(),
                                  controller: controller,
                                  emptyWidget: getEmptyWidget(),
                                );
                              },
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }

  void onTap(GameWithCourtMapResponse model, BuildContext context) {
    Map<String, String> pathParameters = {'gameId': model.id.toString()};
    context.pushNamed(
      GameDetailScreen.routeName,
      pathParameters: pathParameters,
    );
  }

  void selectRegion(String? region) {
    final district =
        region == '지역' ? null : DistrictType.stringToEnum(value: region!);
    final form = ref
        .read(gameSearchProvider.notifier)
        .update(district: district, isAll: district == null);
    ref
        .read(dropDownValueProvider(DropButtonType.district).notifier)
        .update((state) => region);
    ref.read(gamePageProvider(PaginationStateParam()).notifier).paginate(
        paginationParams: const PaginationParam(page: 1),
        forceRefetch: true,
        param: form);
  }

  void searchGame(String value) {
    final form = ref.read(gameSearchProvider.notifier).update(title: value);
    ref
        .read(gamePageProvider(PaginationStateParam()).notifier)
        .updateDebounce(param: form);
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '경기가 없습니다!',
          style: MITITextStyle.xxl140.copyWith(color: Colors.white),
        ),
        SizedBox(height: 20.h),
        Text(
          '직접 경기를 생성하여 참가자를 모집해보세요!',
          style: MITITextStyle.sm150.copyWith(color: MITIColor.gray300),
        )
      ],
    );
  }
}

class _GameSearchCard extends StatelessWidget {
  final int id;
  final GameStatusType gameStatus;
  final String title;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final int minInvitation;
  final int maxInvitation;
  final int numOfParticipations;
  final int fee;
  final String info;
  final CourtMapResponse court;
  final VoidCallback onTap;

  const _GameSearchCard(
      {super.key,
      required this.id,
      required this.gameStatus,
      required this.title,
      required this.startDate,
      required this.startTime,
      required this.endDate,
      required this.endTime,
      required this.minInvitation,
      required this.maxInvitation,
      required this.numOfParticipations,
      required this.fee,
      required this.info,
      required this.court,
      required this.onTap});

  factory _GameSearchCard.fromModel(
      {required GameWithCourtMapResponse model, required VoidCallback onTap}) {
    return _GameSearchCard(
      id: model.id,
      gameStatus: model.gameStatus,
      title: model.title,
      startDate: model.startDate,
      startTime: model.startTime,
      endDate: model.endDate,
      endTime: model.endTime,
      minInvitation: model.minInvitation,
      maxInvitation: model.maxInvitation,
      numOfParticipations: model.numOfParticipations,
      fee: model.fee,
      info: model.info,
      court: model.court,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final month = DateTime.parse(startDate).month;
    final day = DateTime.parse(startDate).day;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xFF4B4B4B), width: 1.h),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GameStateLabel(gameStatus: gameStatus),
                      SizedBox(height: 8.h),
                      Text(
                        title,
                        style: MITITextStyle.mdBold150.copyWith(
                          color: MITIColor.gray200,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: MITIColor.gray750,
                      borderRadius: BorderRadius.circular(4.r)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '$month',
                            style: MITITextStyle.xxxsm
                                .copyWith(color: MITIColor.white),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '월',
                            style: MITITextStyle.xxxsmLight
                                .copyWith(color: MITIColor.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$day',
                        style: MITITextStyle.smBold.copyWith(
                          color: MITIColor.white,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          AssetUtil.getAssetPath(
                            type: AssetType.icon,
                            name: "clock",
                          ),
                          width: 16.r,
                          height: 16.r,
                          colorFilter: const ColorFilter.mode(
                              MITIColor.gray500, BlendMode.srcIn),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${startTime.substring(0, 5)} ~ ${endTime.substring(0, 5)}',
                          style: MITITextStyle.xxsm.copyWith(
                            color: MITIColor.gray300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icon/people.svg',
                          colorFilter: const ColorFilter.mode(
                              MITIColor.gray500, BlendMode.srcIn),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          '$numOfParticipations/$maxInvitation',
                          style: MITITextStyle.xxsm.copyWith(
                            color: MITIColor.gray300,
                          ),
                        )
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final position = ref.watch(positionProvider);
                        NLatLng? myPosition;
                        double? distance;
                        String formatDistance = ' m';
                        if (position != null) {
                          myPosition =
                              NLatLng(position.latitude, position.longitude);

                          distance = myPosition.distanceTo(NLatLng(
                              double.parse(court.latitude),
                              double.parse(court.longitude)));

                          if (distance > 1000) {
                            distance /= 1000;
                            distance = distance.ceil().toDouble();
                            formatDistance = ' km';
                          }
                        }
                        formatDistance = distance.toString() + formatDistance;

                        if (distance != null) {
                          return Row(
                            children: [
                              SvgPicture.asset(
                                AssetUtil.getAssetPath(
                                  type: AssetType.icon,
                                  name: "map_pin",
                                ),
                                colorFilter: const ColorFilter.mode(
                                    MITIColor.gray500, BlendMode.srcIn),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                formatDistance,
                                style: MITITextStyle.xxsm.copyWith(
                                  color: MITIColor.gray300,
                                ),
                              )
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                ),
                if (fee != 0)
                  Row(
                    children: [
                      Text(
                        '$fee',
                        style: MITITextStyle.mdBold.copyWith(
                          color: MITIColor.primary,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '원',
                        style: MITITextStyle.mdBold.copyWith(
                          color: MITIColor.primary,
                        ),
                      )
                    ],
                  )
                else
                  Text(
                    '무료',
                    style: MITITextStyle.mdBold.copyWith(
                      color: MITIColor.primary,
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
