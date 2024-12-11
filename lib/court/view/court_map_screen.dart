import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/component/custom_time_picker.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/component/court_component.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/game/param/game_param.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_filter_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';

import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../../game/view/game_detail_screen.dart';
import '../model/court_model.dart';

final selectGameListProvider =
    StateProvider.autoDispose<List<GameModel>>((ref) => []);
final selectMakerProvider = StateProvider.autoDispose<int?>((ref) => null);
final scrollControllerProvider =
    StateProvider.autoDispose<ScrollController?>((ref) => null);
final showFilterProvider = StateProvider.autoDispose((ref) => false);

class CourtMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'home';

  const CourtMapScreen({
    super.key,
  });

  @override
  ConsumerState<CourtMapScreen> createState() => _HomeScreenState();
}

final positionProvider = StateProvider.autoDispose<Position?>((ref) => null);

class _HomeScreenState extends ConsumerState<CourtMapScreen>
    with AutomaticKeepAliveClientMixin {
  late final DraggableScrollableController _draggableScrollableController;
  NaverMapController? _mapController;
  late final Box<bool> permissionBox;

  @override
  bool get wantKeepAlive => true; //override with True.
  @override
  void initState() {
    super.initState();
    log('page init!!');
    _draggableScrollableController = DraggableScrollableController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startApp();
    });
  }

  Future<void> startApp() async {
    permissionBox = Hive.box('permission');
    final display = permissionBox.get('permission');
    if (display == null) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (_) {
              return const _PermissionComponent();
            });
      }
    }
  }

  @override
  void dispose() {
    _draggableScrollableController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    log('permission = $permission');
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await transitionMap();
    } else if (permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await transitionMap();
      }
    } else {
      if (mounted) {
        ref.read(positionProvider.notifier).update((state) => null);
      }
    }
  }

  Future<void> transitionMap() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      ref.read(positionProvider.notifier).update((state) => position);
      await _mapController!
          .setLocationTrackingMode(NLocationTrackingMode.follow);
      await _mapController?.updateCamera(NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(
        position.latitude,
        position.longitude,
      )));
    } catch (e) {
      print(e);
    }
  }

  void _showPermissionDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return const PermissionDialog(
            title: '설정>개인정보보호>위치서비스와\n설정>MITI에서 위치 정보 접근을\n모두 허용해 주세요.',
          );
        });
  }

  Future<bool> _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    log('requestStatus = $requestStatus, status = $status');

    if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
      // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
      print("isPermanentlyDenied");
      _showPermissionDialog();

      return false;
    } else if (status.isRestricted) {
      // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
      print("isRestricted");
      _showPermissionDialog();

      return false;
    } else if (status.isDenied) {
      // 권한 요청 거절
      print("isDenied");
      _showPermissionDialog();
      return false;
    } else {
      print("requestStatus ${requestStatus.name}");
      print("status ${status.name}");
      await transitionMap();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(showFilterProvider, (previous, next) {
      if (next) {
        _draggableScrollableController.reset();
      }
    });

    // log('page build!!');
    final position = ref.watch(positionProvider);
    final select = ref.watch(selectMakerProvider);

    ref.listen(gameListProvider, (previous, next) {
      log("listen gameListProvider");
      if (_mapController != null) {
        if (next is LoadingModel) {
        } else if (next is ErrorModel) {
        } else {
          refreshMarker(next);
        }
      }
    });

    // log('position = ${position}');
    return Stack(
      children: [
        NaverMap(
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(37.5666, 126.979),
              zoom: 15,
            ),
            locale: Locale('ko'),
          ),
          onMapTapped: (NPoint point, NLatLng latLng) {
            // print("tap point = $point latLng = $latLng");
            ref.read(showFilterProvider.notifier).update((state) => !state);
          },
          onMapReady: (controller) async {
            log('controller Map Loading');

            /// marker를 이미지로 생성할 시 준비과정 중 사용할 이미지들을 캐싱 필요
            /// 하지 않을 경우 사용하지 않은 이미지를 사용할 때 캐싱되지 않아 display 되지 않음
            // final Set<NAddableOverlay> cacheImageMarker = {};
            // for (int i = 0; i < 4; i++) {
            //   final marker = await CustomMarker(
            //           model: MapMarkerModel(
            //               id: i,
            //               time: '',
            //               cost: '',
            //               moreCnt: i % 2 == 0 ? 2 : 1,
            //               latitude: 120,
            //               longitude: 35))
            //       .getMarker(context, selected: i > 1);
            //   cacheImageMarker.add(marker);
            // }
            // await controller.addOverlayAll(cacheImageMarker);
            _mapController = controller;
            // await getLocation();
          },
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final visible = ref.watch(showFilterProvider);
            return Visibility(
                visible: visible,
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFF000000).withOpacity(0.64)),
                ));
          },
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final visible = ref.watch(showFilterProvider);
            if (visible) {
              return const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _FilterComponent(),
              );
            }
            return Positioned(
              child: SafeArea(
                  child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: const _FilterChipsComponent(
                        inFilter: false,
                      ))),
            );
          },
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final visible = ref.watch(showFilterProvider);
            return Visibility(visible: !visible, child: child!);
          },
          child: Positioned(
            left: 12.w,
            bottom: 50.h,
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                  color:
                      position != null ? const Color(0xFFE9FFFF) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        position != null ? MITIColor.primary : MITIColor.gray50,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.25),
                        blurRadius: 10.r)
                  ]),
              child: GestureDetector(
                onTap: () async {
                  if (position == null) {
                    _permission();
                  } else {
                    ref.read(positionProvider.notifier).update((state) => null);
                    await _mapController!
                        .setLocationTrackingMode(NLocationTrackingMode.none);
                  }
                },
                child: SvgPicture.asset(
                  AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: position != null ? "gps" : "un_gps"),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          child: DraggableScrollableSheet(
            initialChildSize: 0.04,
            // 0.04
            maxChildSize: 0.85,
            minChildSize: 0.04,
            snap: true,
            controller: _draggableScrollableController,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                    color: MITIColor.gray900,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.r))),
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    // 내용
                    Positioned.fill(
                      top: 0.h,
                      left: 0,
                      right: 0,
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 62.h,
                            ),
                          ),
                          Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              final modelList =
                                  ref.watch(selectGameListProvider);
                              return SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 21.w),
                                sliver: _getCourtComponent(modelList),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // 핸들 부분
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                              color: MITIColor.gray900,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.r))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 8.h),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 4.h,
                                  width: 60.w,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.r)),
                                    color: MITIColor.gray100,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Consumer(builder: (_, ref, child) {
                                final modelList =
                                    ref.watch(selectGameListProvider);
                                if (modelList.isNotEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(left: 33.w),
                                    child: Text(
                                      '${modelList.length}개의 매치',
                                      style: MITITextStyle.selectionDayStyle
                                          .copyWith(
                                        color: MITIColor.gray100,
                                      ),
                                    ),
                                  );
                                }
                                return Container();
                              }),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _getCourtComponent(List<GameModel> modelList) {
    if (modelList.isEmpty) {
      return SliverToBoxAdapter(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 250.h),
          Text(
            '검색된 경기가 없습니다.',
            style: MITITextStyle.xxl140.copyWith(color: MITIColor.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Text(
            '필터를 변경하여 다른 경기를 찾아보세요!',
            style: MITITextStyle.sm.copyWith(color: MITIColor.gray300),
            textAlign: TextAlign.center,
          ),
        ],
      ));
    }
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      sliver: SliverList.separated(
        itemBuilder: (_, idx) {
          return CourtCard.fromModel(model: modelList[idx]);
        },
        separatorBuilder: (_, idx) {
          return SizedBox(height: 12.h);
        },
        itemCount: modelList.length,
      ),
    );
  }

  void refreshMarker(BaseModel response) async {
    // log('refreshMarker');
    final model = (response as ResponseListModel<GameModel>).data!;
    Map<MapPosition, List<GameModel>> markers = {};

    for (GameModel value in model) {
      final mapPosition = MapPosition(
          longitude: double.parse(value.court.longitude),
          latitude: double.parse(value.court.latitude));
      // log('mapPosition ${mapPosition}');
      if (markers.containsKey(mapPosition)) {
        markers[mapPosition]!.add(value);
      } else {
        markers[mapPosition] = [value];
      }
    }
    // log('_mapController = ${_mapController}');

    // _mapController!.getLocationOverlay()
    await _mapController?.clearOverlays();
    final List<MapMarkerModel> markerList = [];
    for (MapPosition key in markers.keys) {
      final GameModel model = markers[key]!.first;
      final fee = model.fee == 0
          ? "무료 경기"
          : '₩${NumberFormat.decimalPattern().format(model.fee)}';

      markerList.add(MapMarkerModel(
          time: '${model.starttime.substring(0, 5)}~',
          cost: fee,
          moreCnt: markers[key]!.length,
          id: model.id,
          latitude: key.latitude,
          longitude: key.longitude));
    }

    final customMarkerList =
        markerList.map((e) => CustomMarker(model: e)).toList();

    final futureMarkerList = markerList
        .map((e) => CustomMarker(model: e).getMarker(context))
        .toList();


    for (int i = 0; i < futureMarkerList.length; i++) {
      final marker = await futureMarkerList[i];

      marker.setOnTapListener((NMarker overlay) async {
        final key = MapPosition(
            longitude: overlay.position.longitude,
            latitude: overlay.position.latitude);
        log('key ${key}');

        ref
            .read(selectGameListProvider.notifier)
            .update((state) => markers[key]!);

        /// 하나일 경우
        if (markers[key]!.length == 1) {
          Map<String, String> pathParameters = {
            'gameId': markers[key]!.first.id.toString()
          };
          final Map<String, String> queryParameters = {'bottomIdx': '0'};
          context.pushNamed(GameDetailScreen.routeName,
              pathParameters: pathParameters, queryParameters: queryParameters);
        }

        _draggableScrollableController.animateTo(
          0.9,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        await _mapController?.updateCamera(NCameraUpdate.fromCameraPosition(
            NCameraPosition(
                target: NLatLng(
                    overlay.position.latitude, overlay.position.longitude),
                zoom: 15)));
        for (int j = 0; j < futureMarkerList.length; j++) {
          final compareMarker = await futureMarkerList[j];

          if (marker.info.id != compareMarker.info.id) {
            ///선택 해제 마커
            // log('마커 선택 해제');
            final findMarker = customMarkerList.firstWhere(
                (e) => e.model.id.toString() == compareMarker.info.id);
            if (mounted) {
              final value = await findMarker.getNOverlayImage(context);
              compareMarker.setIcon(value);
            }
          }
        }

        final findMarker = customMarkerList
            .firstWhere((e) => e.model.id.toString() == marker.info.id);

        /// 선택된 마커
        if (mounted) {
          final value =
              await findMarker.getNOverlayImage(context, selected: true);

          overlay.setIcon(value);
        }
      });
    }
    final Set<NMarker> allOverlay = {};
    for (var o in futureMarkerList) {
      final value = await o;
      allOverlay.add(value);
    }
    futureMarkerList.map((e) async {
      return await e;
    });
    if (_mapController != null) {
      await _mapController?.addOverlayAll(allOverlay);
    }
  }
}

class CourtCard extends StatelessWidget {
  final int id;
  final GameStatus game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final String fee;
  final CourtModel? court;
  final int num_of_participations;
  final int max_invitation;

  const CourtCard({
    super.key,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.fee,
    required this.court,
    required this.num_of_participations,
    required this.max_invitation,
    required this.id,
  });

  factory CourtCard.fromModel({required GameModel model}) {
    final fee = model.fee == 0
        ? '무료'
        : "₩${NumberFormat.decimalPattern().format(model.fee)}";
    return CourtCard(
      game_status: model.game_status,
      title: model.title,
      startdate: model.startdate,
      starttime: model.starttime,
      enddate: model.enddate,
      endtime: model.endtime,
      fee: fee,
      court: model.court,
      num_of_participations: model.num_of_participations,
      max_invitation: model.max_invitation,
      id: model.id,
    );
  }

  factory CourtCard.fromSoonestGameModel({required GameHostModel model}) {
    final fee = model.fee == 0
        ? '무료'
        : "₩${NumberFormat.decimalPattern().format(model.fee)}";
    return CourtCard(
      game_status: model.game_status,
      title: model.title,
      startdate: model.startdate,
      starttime: model.starttime,
      enddate: model.enddate,
      endtime: model.endtime,
      fee: fee,
      num_of_participations: model.num_of_participations,
      max_invitation: model.max_invitation,
      id: model.id,
      court: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Map<String, String> pathParameters = {'gameId': id.toString()};
        Map<String, String> queryParameters = {'bottomIdx': '0'};
        context.pushNamed(GameDetailScreen.routeName,
            pathParameters: pathParameters, queryParameters: queryParameters);
      },
      child: Container(
        decoration: BoxDecoration(
            color: MITIColor.gray700,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: MITIColor.gray600)),
        padding: EdgeInsets.all(16.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameStateLabel(gameStatus: game_status),
                  SizedBox(height: 8.h),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MITITextStyle.mdBold.copyWith(
                      color: MITIColor.gray200,
                    ),
                  ),
                  SizedBox(height: 12.h),
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
                        '${starttime.substring(0, 5)} ~ ${endtime.substring(0, 5)}',
                        style: MITITextStyle.xxsm.copyWith(
                          color: MITIColor.gray300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/icon/people.svg',
                                colorFilter: const ColorFilter.mode(
                                    MITIColor.gray500, BlendMode.srcIn),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                '$num_of_participations/$max_invitation',
                                style: MITITextStyle.xxsm.copyWith(
                                  color: MITIColor.gray300,
                                ),
                              )
                            ],
                          ),
                          SizedBox(width: 12.w),
                          Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              final position = ref.watch(positionProvider);
                              NLatLng? myPosition;
                              double? distance;
                              String formatDistance = ' m';
                              if (position != null && court != null) {
                                myPosition = NLatLng(
                                    position.latitude, position.longitude);

                                distance = myPosition.distanceTo(NLatLng(
                                    double.parse(court!.latitude),
                                    double.parse(court!.longitude)));

                                if (distance > 1000) {
                                  distance /= 1000;
                                  distance = distance.ceil().toDouble();
                                  formatDistance = ' km';
                                }
                              }
                              formatDistance =
                                  distance.toString() + formatDistance;

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
                          ),
                        ],
                      ),
                      Text(
                        '$fee',
                        textAlign: TextAlign.right,
                        style: MITITextStyle.mdBold.copyWith(
                          color: MITIColor.primary,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapMarker extends StatelessWidget {
  const MapMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

final selectedDayProvider = StateProvider.autoDispose<DateTime>((ref) {
  return DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
});

class DateBox extends ConsumerWidget {
  final DateTime day;
  final String dayOfWeek;
  final GlobalKey gKey;
  final VoidCallback onTap;

  const DateBox({
    super.key,
    required this.day,
    required this.dayOfWeek,
    required this.gKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectDay = day.day;
    final startdateByString =
        ref.watch(gameFilterProvider.select((value) => value.startdate));

    final selectedDay = startdateByString != null
        ? DateTime.parse(startdateByString)
        : DateTime.now();
    DateTime.parse(DateFormat('yyyy-MM-dd').format(selectedDay));

    final isSelect = selectedDay.day == selectDay;
    return InkWell(
        key: gKey,
        onTap: onTap,
        child: Column(
          children: [
            Text(
              dayOfWeek,
              style: MITITextStyle.xxsm.copyWith(
                color: dayOfWeek == "일"
                    ? MITIColor.error
                    : isSelect
                        ? MITIColor.gray100
                        : MITIColor.gray600,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 32.r,
              width: 32.r,
              decoration: isSelect
                  ? const BoxDecoration(
                      shape: BoxShape.circle,
                      color: MITIColor.primary,
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                '$selectDay',
                style: MITITextStyle.smBold.copyWith(
                  color: isSelect ? MITIColor.gray900 : MITIColor.gray600,
                ),
              ),
            )
          ],
        ));
  }
}

class _FilterComponent extends ConsumerStatefulWidget {
  const _FilterComponent({super.key});

  @override
  ConsumerState<_FilterComponent> createState() => _FilterComponentState();
}

class _FilterComponentState extends ConsumerState<_FilterComponent> {
  /// 처음 들어온 필터 상태
  late final GameListParam joinFilter;
  late final ScrollController _dayScrollController;
  late final FixedExtentScrollController timePeriodController;
  late final FixedExtentScrollController hourController;
  late final FixedExtentScrollController minController;
  final List<GlobalKey> dayKeys = [];
  String date = "";
  bool isAfternoon = false;
  int selectedHour = 0;
  int selectedMinute = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < 14; i++) {
      dayKeys.add(GlobalKey());
    }
    timePeriodController =
        FixedExtentScrollController(initialItem: isAfternoon ? 1 : 0);
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minController =
        FixedExtentScrollController(initialItem: selectedMinute ~/ 10);

    _dayScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      joinFilter = ref.read(gameFilterProvider);
      final time = joinFilter.starttime!.split(':');
      final hour = int.parse(time[0]);
      final min = int.parse(time[1]);
      timePeriodController.jumpToItem(hour >= 12 ? 1 : 0);
      hourController.jumpToItem(hour % 12);
      minController.jumpToItem(min ~/ 10);
    });
  }

  void selectDay(List<List<String>> day, int idx) {
    ref.read(gameFilterProvider.notifier).update(startdate: day[idx][0]);
    Scrollable.ensureVisible(
      dayKeys[idx].currentContext!,
      alignment: 0.5,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    timePeriodController.dispose();
    hourController.dispose();
    minController.dispose();
    _dayScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.only(
      left: 21.w,
      right: 21.w,
      top: 20.h,
      bottom: 24.h,
    );
    const border = BoxDecoration(
        border: Border(bottom: BorderSide(color: MITIColor.gray700)));

    final dateTime = DateTime.now();
    List<DateTime> dateTimes = [];
    final dateFormat = DateFormat('yyyy-MM-dd E', 'ko');
    for (int i = 0; i < 14; i++) {
      dateTimes.add(dateTime.add(Duration(days: i)));
    }
    final day = dateTimes.map((e) {
      return dateFormat.format(e).split(' ');
    }).toList();
    // final selectedMonth = ref.watch(selectedDayProvider).month;
    final startdateByString =
        ref.watch(gameFilterProvider.select((value) => value.startdate));
    final selectedMonth = startdateByString != null
        ? DateTime.parse(startdateByString).month
        : DateTime.now().month;

    return Container(
      color: MITIColor.gray800,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: border,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const _FilterChipsComponent(
                inFilter: true,
              ),
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                // final startDate = ref
                //     .watch(gameFilterProvider.select((value) => value.startdate));

                return Container(
                  decoration: border,
                  padding: EdgeInsets.only(
                    top: 20.h,
                    bottom: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 21.w,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "날짜",
                              style: MITITextStyle.smSemiBold.copyWith(
                                color: MITIColor.gray50,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "$selectedMonth월",
                              style: MITITextStyle.xxsm.copyWith(
                                color: MITIColor.gray300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SingleChildScrollView(
                        controller: _dayScrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 21.w,
                        ),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...day.mapIndexed((idx, element) {
                              final date = day[idx][0].split('-');
                              final month =
                                  date[1][0] == '0' ? date[1][1] : date[1];

                              final bool showYear =
                                  month == '1' && date[2] == '01';
                              final bool showMonth = date[2] == '01';
                              return Row(
                                children: [
                                  if (showMonth)
                                    Padding(
                                      padding: EdgeInsets.only(right: 16.w),
                                      child: Column(
                                        children: [
                                          if (showYear)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 5.h),
                                              child: Text(
                                                date[0],
                                                style:
                                                    MITITextStyle.xxsm.copyWith(
                                                  color: MITIColor.primary,
                                                ),
                                              ),
                                            ),
                                          Text(
                                            "$month월",
                                            style: MITITextStyle.smBold
                                                .copyWith(
                                                    color: MITIColor.primary),
                                          )
                                        ],
                                      ),
                                    ),
                                  DateBox(
                                    day: DateTime.parse(day[idx][0]),
                                    dayOfWeek: day[idx][1],
                                    gKey: dayKeys[idx],
                                    onTap: () {
                                      selectDay(day, idx);
                                    },
                                  ),
                                  if (idx != day.length - 1)
                                    SizedBox(width: 16.w),
                                ],
                              );
                            })
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Container(
              padding: padding,
              decoration: border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "시간",
                    style: MITITextStyle.smSemiBold.copyWith(
                      color: MITIColor.gray50,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                            height: 96.h,
                            child: CustomTimePicker(
                              timePeriodController: timePeriodController,
                              hourController: hourController,
                              minController: minController,
                            )),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        "이후 경기",
                        style:
                            MITITextStyle.sm.copyWith(color: MITIColor.gray100),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: padding,
              decoration: border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "경기 상태",
                    style: MITITextStyle.smSemiBold
                        .copyWith(color: MITIColor.gray50),
                  ),
                  SizedBox(height: 12.h),
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final gameStatus = ref.watch(gameFilterProvider
                          .select((value) => value.gameStatus));

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: GameStatus.values
                            .map((e) => _GameStatusButton(
                                status: e,
                                selected: gameStatus.isNotEmpty
                                    ? gameStatus.contains(e)
                                    : false))
                            .toList(),
                      );
                    },
                  )
                ],
              ),
            ),
            Container(
              padding: padding,
              decoration: border,
              child: Row(
                children: [
                  TextButton(
                      onPressed: filterClear,
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            MITIColor.gray500,
                          ),
                          minimumSize:
                              WidgetStateProperty.all(Size(98.w, 48.h)),
                          maximumSize:
                              WidgetStateProperty.all(Size(98.w, 48.h)),
                          fixedSize: WidgetStateProperty.all(Size(98.w, 48.h))),
                      child: Text(
                        "초기화",
                        style:
                            MITITextStyle.md.copyWith(color: MITIColor.gray50),
                      )),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        ref.read(gameListProvider.notifier).getList();
                        ref
                            .read(showFilterProvider.notifier)
                            .update((state) => false);
                      },
                      style: ButtonStyle(
                          minimumSize:
                              WidgetStateProperty.all(Size(223.w, 48.h)),
                          maximumSize:
                              WidgetStateProperty.all(Size(223.w, 48.h)),
                          fixedSize:
                              WidgetStateProperty.all(Size(223.w, 48.h))),
                      child: const Text(
                        "적용하기",
                      )),
                ],
              ),
            ),

            /// todo 수정 필요
            GestureDetector(
              onTap: () {
                ref.read(gameFilterProvider.notifier).rollback(joinFilter);
                ref.read(showFilterProvider.notifier).update((state) => false);
              },
              child: SizedBox(
                height: 21.h,
                width: double.infinity,
                child: const Icon(
                  Icons.keyboard_arrow_up_outlined,
                  color: MITIColor.primary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void filterClear() {
    ref.read(gameFilterProvider.notifier).clear();
    _dayScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    timePeriodController.animateToItem(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    hourController.animateToItem(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    minController.animateToItem(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }
}

class _GameStatusButton extends ConsumerWidget {
  final GameStatus status;
  final bool selected;

  const _GameStatusButton(
      {super.key, required this.status, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final filterStatus = ref.read(gameFilterProvider).gameStatus;
        //선택 된 상태면 선택 해제
        if (selected) {
          log("선택 된 상태면 선택 해제");
          ref.read(gameFilterProvider.notifier).deleteStatus(status);
        } else {
          if (filterStatus.isNotEmpty) {
            // 하나 이상 선택된 상태
            log("하나 이상 선택된 상태");
            ref.read(gameFilterProvider.notifier).addStatus(status);
          } else {
            //아무것도 선택 안된 상태
            log("아무것도 선택 안된 상태");
            ref.read(gameFilterProvider.notifier).initStatus(status);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: MITIColor.gray800,
            border: Border.all(
              color: selected ? MITIColor.primary : MITIColor.gray500,
            ),
            borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.all(10.r),
        child: Text(
          status.displayName,
          style: MITITextStyle.sm.copyWith(
            color: selected ? MITIColor.primary : MITIColor.gray400,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends ConsumerWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool inFilter;

  const _FilterChip(
      {super.key,
      required this.title,
      required this.selected,
      required this.onTap,
      required this.inFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: !inFilter
          ? () {
              ref.read(showFilterProvider.notifier).update((state) => !state);
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            color: inFilter ? MITIColor.gray700 : MITIColor.gray800),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            Text(
              title,
              style: selected
                  ? MITITextStyle.smSemiBold.copyWith(color: MITIColor.primary)
                  : MITITextStyle.sm.copyWith(
                      color: inFilter ? MITIColor.gray100 : MITIColor.gray50),
            ),
            if (selected && inFilter)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: GestureDetector(
                  onTap: onTap,
                  child: SvgPicture.asset(
                    AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: 'close2',
                    ),
                    colorFilter: const ColorFilter.mode(
                        MITIColor.primary, BlendMode.srcIn),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _FilterChipsComponent extends StatelessWidget {
  final bool inFilter;

  const _FilterChipsComponent({super.key, required this.inFilter});

  String parsingStatus(GameListParam filter) {
    filter.gameStatus.sort((f1, f2) {
      return f1.index - f2.index;
    });
    String gameStatus = filter.gameStatus
        .fold("", (value, element) => "$value${element.displayName}, ");
    if (gameStatus.isNotEmpty) {
      gameStatus = gameStatus.substring(0, gameStatus.length - 2);
    }
    return gameStatus;
  }

  String parsingTime(GameListParam filter) {
    // 시간 문자열을 DateTime 객체로 파싱
    DateTime parsedTime = DateFormat("HH:mm").parse(filter.starttime!);

    // DateTime 객체를 원하는 형식으로 포맷
    String formattedTime = DateFormat("a hh:mm").format(parsedTime);

    // 오전/오후 표시를 추가하여 출력
    String time =
        formattedTime.replaceFirst("AM", "오전").replaceFirst("PM", "오후");
    return time;
  }

  String parsingDate(GameListParam filter) {
    // 1. 문자열을 DateTime 객체로 변환
    DateTime dateTime = DateTime.parse(filter.startdate!);

    // 2. 원하는 형식으로 포맷팅
    String formattedDate = DateFormat('MM-dd').format(dateTime);
    String weekday = DateFormat.E('ko_KR').format(dateTime); // 요일을 한글로 표시

    // 요일을 (토) 형식으로 변환
    String finalString = '$formattedDate ($weekday)';
    return finalString;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      scrollDirection: Axis.horizontal,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final filter = ref.watch(gameFilterProvider);

          String gameStatus = parsingStatus(filter);

          // 1. 문자열을 DateTime 객체로 변환
          String date = parsingDate(filter);

          // 시간 문자열을 DateTime 객체로 파싱
          String time = parsingTime(filter);

          return Row(
            children: [
              _FilterChip(
                title: filter.startdate != null ? date : '날짜',
                selected: filter.startdate != null,
                onTap: () {
                  ref
                      .read(gameFilterProvider.notifier)
                      .removeFilter(FilterType.date);
                },
                inFilter: inFilter,
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                title: filter.starttime != null ? time : '시간',
                selected: filter.startdate != null,
                onTap: () {
                  ref
                      .read(gameFilterProvider.notifier)
                      .removeFilter(FilterType.time);
                },
                inFilter: inFilter,
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                title: gameStatus.isEmpty ? '경기 상태' : gameStatus,
                selected: filter.gameStatus.isNotEmpty,
                onTap: () {
                  ref
                      .read(gameFilterProvider.notifier)
                      .removeFilter(FilterType.status);
                },
                inFilter: inFilter,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PermissionComponent extends StatelessWidget {
  const _PermissionComponent({super.key});

  Widget _permission(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              title,
              style: MITITextStyle.smBold.copyWith(
                color: MITIColor.gray100,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '(선택)',
              style: MITITextStyle.sm.copyWith(
                color: MITIColor.gray300,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          desc,
          style: MITITextStyle.xxsmLight150.copyWith(
            color: MITIColor.gray100,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 333.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: MITIColor.gray800,
        ),
        padding:
            EdgeInsets.only(left: 20.w, right: 20.w, top: 28.h, bottom: 20.h),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '‘MITI’서비스 이용을 위해\n접근권한의 허용이 필요합니다.',
                style: MITITextStyle.mdBold150.copyWith(
                  color: MITIColor.gray100,
                ),
                textAlign: TextAlign.center,
              ),
              Divider(height: 41.h, color: MITIColor.gray600),
              _permission('알림', '경기 상태 등 서비스 알림 전송'),
              SizedBox(height: 20.h),
              _permission('위치설정', '주변 경기 및 경기장 추천'),
              SizedBox(height: 40.h),
              TextButton(
                onPressed: () async {
                  await Permission.location.request();
                  await Permission.notification.request();
                  final Box<bool> permissionBox = Hive.box('permission');
                  await permissionBox.put('permission', false);
                  if (context.mounted) {
                    context.pop();
                  }
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
