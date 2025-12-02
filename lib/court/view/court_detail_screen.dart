import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/provider/court_provider.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/naver_map_util.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/share_fab_component.dart';
import '../../game/component/game_card.dart';
import '../../util/util.dart';
import '../component/skeleton/court_detail_skeleton.dart';
import '../model/v2/court_operations_response.dart';
import 'court_game_list_screen.dart';

class CourtDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'courtDetail';

  // final CourtSearchModel model;
  final int courtId;

  const CourtDetailScreen({
    super.key,
    required this.courtId,
    // required this.model,
  });

  @override
  ConsumerState<CourtDetailScreen> createState() => _CourtGameListScreenState();
}

class _CourtGameListScreenState extends ConsumerState<CourtDetailScreen> {
  late final FocusNode focusNode;
  late final ScrollController _scrollController;
  final fabKey = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    fabKey.currentState?.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(courtDetailProvider(courtId: widget.courtId));
    if (result is LoadingModel) {
      return const CourtDetailSkeleton();
    } else if (result is ErrorModel) {
      return Text("Error");
    }

    final model = (result as ResponseModel<CourtOperationsResponse>).data!;

    return SelectableRegion(
      focusNode: focusNode,
      selectionControls: materialTextSelectionControls,
      child: Scaffold(
        backgroundColor: MITIColor.gray750,
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return ShareFabComponent(
              id: widget.courtId,
              type: ShareType.courts,
              globalKey: fabKey,
              model: model,
            );
          },
        ),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              DefaultAppBar(
                title: model.name,
                backgroundColor: MITIColor.gray750,
                isSliver: true,
                hasBorder: false,
              )
            ];
          },
          body: CustomScrollView(
            slivers: [
              SliverMainAxisGroup(slivers: [
                SliverToBoxAdapter(
                  child: CourtMapComponent(
                    latLng: NLatLng(
                      double.parse(model.latitude),
                      double.parse(model.longitude),
                    ),
                  ),
                ),
                _CourtInfoComponent(
                  model: model,
                ),
                getDivider(),
                SoonestGamesComponent(
                  courtId: widget.courtId,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter getDivider() {
    return SliverToBoxAdapter(
      child: Divider(
        indent: 16.w,
        endIndent: 16.w,
        color: MITIColor.gray700,
        height: 16.h,
        thickness: 1.h,
      ),
    );
  }
}

class CourtMapComponent extends StatefulWidget {
  final NLatLng latLng;

  const CourtMapComponent({super.key, required this.latLng});

  @override
  State<CourtMapComponent> createState() => CourtMapComponentState();
}

class CourtMapComponentState extends State<CourtMapComponent> {
  late final NaverMapController _naverMapController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: widget.latLng,
            zoom: 12,
          ),
          locale: const Locale('ko'),
          logoClickEnable: false,
        ),
        onMapReady: (controller) async {
          _naverMapController = controller;
          final icon = NOverlayImage.fromAssetImage(
            AssetUtil.getAssetPath(
                type: AssetType.icon, name: 'location', extension: 'png'),
          );
          await _naverMapController.addOverlay(
              NMarker(id: '1', position: widget.latLng, icon: icon));
        },
      ),
    );
  }
}

class _CourtInfoComponent extends ConsumerWidget {
  final CourtOperationsResponse model;

  const _CourtInfoComponent({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              model.name ?? '미정',
              style: MITITextStyle.lgBold.copyWith(color: MITIColor.gray100),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () async {
                await NaverMapUtil.searchRoute(
                  destinationAddress:
                      "${model.address} ${model.addressDetail ?? ''}",
                  destinationLat: double.parse(model.latitude),
                  destinationLng: double.parse(model.longitude),
                );
              },
              child: Text(
                "${model.address} ${model.addressDetail ?? ''}",
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.primary,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            if (model.info != null)
              Text(
                model.info!,
                style: MITITextStyle.sm150.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SoonestGamesComponent extends StatelessWidget {
  final int courtId;

  const SoonestGamesComponent({super.key, required this.courtId});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding:
            EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 20.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "이 경기장에 생성된 경기",
                  style: MITITextStyle.lgBold.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final result =
                        ref.watch(courtDetailProvider(courtId: courtId));
                    if (result is LoadingModel) {
                      return const CircularProgressIndicator();
                    } else if (result is ErrorModel) {
                      return const Text("Error");
                    }
                    final model =
                        (result as ResponseModel<CourtOperationsResponse>)
                            .data!;
                    if (model.soonestGames.isEmpty) {
                      return Container();
                    }
                    return GestureDetector(
                      onTap: () {
                        pushGameList(context);
                      },
                      child: Row(
                        children: [
                          Text(
                            '더보기',
                            style: MITITextStyle.xxsmLight.copyWith(
                              color: MITIColor.gray100,
                            ),
                          ),
                          SvgPicture.asset(
                            AssetUtil.getAssetPath(
                              type: AssetType.icon,
                              name: 'chevron_right',
                            ),
                            colorFilter: const ColorFilter.mode(
                              MITIColor.gray400,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
            SizedBox(height: 20.h),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final result = ref.watch(courtDetailProvider(courtId: courtId));
                if (result is LoadingModel) {
                  return const CircularProgressIndicator();
                } else if (result is ErrorModel) {
                  return const Text("Error");
                }
                final model =
                    (result as ResponseModel<CourtOperationsResponse>).data!;

                if (model.soonestGames.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(height: 80.h),
                      Text(
                        "아직 생성된 경기가 없습니다.",
                        style:
                            MITITextStyle.md.copyWith(color: MITIColor.gray300),
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(GameCreateScreen.routeName,
                              extra: model);
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 12.w, right: 16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.r),
                            color: MITIColor.primary,
                          ),
                          height: 36.h,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: MITIColor.gray800,
                              ),
                              Text(
                                '경기 생성하기',
                                style: MITITextStyle.md.copyWith(
                                  color: MITIColor.gray800,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }

                final modelMap = ref
                    .read(courtDetailProvider(courtId: courtId).notifier)
                    .groupAndSortByStartDate();

                return Column(
                  children: [
                    // ListView.separated(
                    //     itemBuilder: (_, idx) {},
                    //     separatorBuilder: (_, idx) {},
                    //     itemCount: itemCount),
                    ListView.separated(
                      itemBuilder: (_, idx) {
                        return CourtCard.fromSoonestGameModel(
                            model: model.soonestGames[idx]);
                      },
                      separatorBuilder: (_, idx) => SizedBox(
                        height: 12.h,
                      ),
                      itemCount: model.soonestGames.length,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                    SizedBox(height: 20.h),
                    TextButton(
                      onPressed: () {
                        pushGameList(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: MITIColor.gray750,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: MITIColor.gray400,
                            ),
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text(
                        "경기 더보기",
                        style: MITITextStyle.md.copyWith(
                          color: MITIColor.gray100,
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void pushGameList(BuildContext context) {

    print("클릭된 CourtId = ${courtId}");
    Map<String, String> pathParameters = {'courtId': courtId.toString()};
    context.pushNamed(CourtGameListScreen.routeName,
        pathParameters: pathParameters);
  }
}
