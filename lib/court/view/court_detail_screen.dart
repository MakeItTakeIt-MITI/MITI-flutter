import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/court/component/court_search_card.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:miti/court/param/court_pagination_param.dart';
import 'package:miti/court/provider/court_pagination_provider.dart';
import 'package:miti/court/provider/court_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/component/default_appbar.dart';
import '../../common/model/model_id.dart';
import '../../game/component/game_list_component.dart';
import '../../game/model/game_model.dart';
import '../../util/util.dart';
import 'court_game_list_screen.dart';
import 'court_map_screen.dart';

class CourtDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'courtDetail';
  final CourtSearchModel model;
  final int courtId;

  const CourtDetailScreen({
    super.key,
    required this.courtId,
    required this.model,
  });

  @override
  ConsumerState<CourtDetailScreen> createState() => _CourtGameListScreenState();
}

class _CourtGameListScreenState extends ConsumerState<CourtDetailScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray750,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            DefaultAppBar(
              title: widget.model.name,
              backgroundColor: MITIColor.gray800,
              isSliver: true,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 13.w),
                  child: GestureDetector(
                    onTap: () {
                      Share.share("share");
                    },
                    child: SvgPicture.asset(
                      AssetUtil.getAssetPath(
                        type: AssetType.icon,
                        name: 'share',
                      ),
                      height: 24.r,
                      width: 24.r,
                      colorFilter: const ColorFilter.mode(
                        MITIColor.gray100,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverMainAxisGroup(slivers: [
              SliverToBoxAdapter(
                child: _CourtMapComponent(
                  latLng: NLatLng(
                    double.parse(widget.model.latitude),
                    double.parse(widget.model.longitude),
                  ),
                ),
              ),
              getDivider(),
              _CourtInfoComponent(
                courtId: widget.courtId,
              ),
              getDivider(),
              SoonestGamesComponent(
                courtId: widget.courtId,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter getDivider() {
    return SliverToBoxAdapter(
      child: Container(
        height: 4.h,
        color: MITIColor.gray800,
      ),
    );
  }
}

class _CourtMapComponent extends StatefulWidget {
  final NLatLng latLng;

  const _CourtMapComponent({super.key, required this.latLng});

  @override
  State<_CourtMapComponent> createState() => _CourtMapComponentState();
}

class _CourtMapComponentState extends State<_CourtMapComponent> {
  late final NaverMapController _naverMapController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(13.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: SizedBox(
          height: 200.h,
          child: NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: widget.latLng,
                zoom: 15,
              ),
              logoClickEnable: false,
            ),
            onMapReady: (controller) async {
              _naverMapController = controller;
              final icon = await NOverlayImage.fromWidget(
                  widget: Icon(
                    Icons.location_on_rounded,
                    color: MITIColor.primary,
                  ),
                  size: Size(32.w, 40.h),
                  context: context);
              await _naverMapController.addOverlay(
                  NMarker(id: '1', position: widget.latLng, icon: icon));
            },
          ),
        ),
      ),
    );
  }
}

class _CourtInfoComponent extends ConsumerWidget {
  final int courtId;

  const _CourtInfoComponent({
    super.key,
    required this.courtId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(courtDetailProvider(courtId: courtId));
    if (result is LoadingModel) {
      return SliverToBoxAdapter(
        child: CircularProgressIndicator(),
      );
    } else if (result is ErrorModel) {
      return SliverToBoxAdapter(
        child: Text("Error"),
      );
    }
    final model = (result as ResponseModel<CourtDetailModel>).data!;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              model.name,
              style: MITITextStyle.lgBold.copyWith(color: MITIColor.gray100),
            ),
            SizedBox(height: 8.h),
            Text(
              "${model.address} ${model.address_detail}",
              style: MITITextStyle.lgBold.copyWith(
                color: MITIColor.gray400,
              ),
            ),
            SizedBox(height: 20.h),
            if (model.info != null)
              Text(
                model.info!,
                style: MITITextStyle.lgBold.copyWith(
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
                GestureDetector(
                  onTap: () {
                    pushGameList(context);
                  },
                  child: Row(
                    children: [
                      Text(
                        '더보기',
                        style: MITITextStyle.xxxsmLight.copyWith(
                          color: MITIColor.gray100,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: MITIColor.gray500,
                        size: 12.r,
                      )
                    ],
                  ),
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
                final model = (result as ResponseModel<CourtDetailModel>).data!;

                return Column(
                  children: [
                    ListView.separated(
                      itemBuilder: (_, idx) {
                        // model.soonest_games.

                        return CourtCard.fromSoonestGameModel(
                            model: model.soonest_games[idx]);
                      },
                      separatorBuilder: (_, idx) => SizedBox(
                        height: 12.h,
                      ),
                      itemCount: model.soonest_games.length,
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
    Map<String, String> pathParameters = {'courtId': courtId.toString()};
    context.pushNamed(CourtGameListScreen.routeName,
        pathParameters: pathParameters);
  }
}
