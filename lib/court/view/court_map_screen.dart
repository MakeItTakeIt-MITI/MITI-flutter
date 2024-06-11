import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/component/court_component.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/game/param/game_param.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';

import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../../game/view/game_detail_screen.dart';
import '../../permission_screen.dart';
import '../model/court_model.dart';

final selectGameListProvider =
    StateProvider.autoDispose<List<GameModel>>((ref) => []);
final selectMakerProvider = StateProvider.autoDispose<int?>((ref) => null);
final draggableScrollController =
    StateProvider.autoDispose<ScrollController?>((ref) => null);

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

  @override
  bool get wantKeepAlive => true; //override with True.
  @override
  void initState() {
    super.initState();
    log('page init!!');

    _draggableScrollableController = DraggableScrollableController();
    getLocation();
  }

  @override
  void dispose() {
    _draggableScrollableController.dispose();
    super.dispose();
  }

  void getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    // final permission = await _permission();
    log('permission = $permission');
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        ref.read(positionProvider.notifier).update((state) => position);
        _mapController?.updateCamera(NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(
              position.latitude,
              position.longitude,
            )));
      } catch (e) {
        print(e);
      }


    } else if (permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        try {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          ref.read(positionProvider.notifier).update((state) => position);
          _mapController?.updateCamera(NCameraUpdate.scrollAndZoomTo(
              target: NLatLng(
                position.latitude,
                position.longitude,
              )));
        } catch (e) {
          print(e);
        }
      }
    }else{
      if (mounted) {
        ref.read(positionProvider.notifier).update((state) => null);
        // context.goNamed(PermissionScreen.routeName);
      }
    }
  }

  Future<bool> _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    log('requestStatus = $requestStatus, status = $status');

    if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
      // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
      print("isPermanentlyDenied");
      return false;
    } else if (status.isRestricted) {
      // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
      print("isRestricted");
      return false;
    } else if (status.isDenied) {
      // 권한 요청 거절
      print("isDenied");
      return false;
    }
    print("requestStatus ${requestStatus.name}");
    print("status ${status.name}");
    // final storage = ref.read(secureStorageProvider);
    // await storage.write(key: 'firstJoin', value: 'true');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // log('page build!!');
    final position = ref.watch(positionProvider);
    final select = ref.watch(selectMakerProvider);
    ref.listen(selectedDayProvider, (previous, next) {
      final date = DateFormat('yyyy-MM-dd').format(next);
      ref
          .read(gameListProvider.notifier)
          .getList(param: GameListParam(startdate: date));
    });
    // final response = ref.watch(gameListProvider);
    ref.listen(gameListProvider, (previous, next) {
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
        // if (position != null)
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.5666, 126.979),
                zoom: 15,
              ),
              locale: Locale('ko'),
            ),
            onMapReady: (controller) async {
              log('controller Map Loading');

              /// marker를 이미지로 생성할 시 준비과정 중 사용할 이미지들을 캐싱 필요
              /// 하지 않을 경우 사용하지 않은 이미지를 사용할 때 캐싱되지 않아 display 되지 않음
              final Set<NAddableOverlay> cacheImageMarker = {};
              for (int i = 0; i < 4; i++) {
                final marker = await CustomMarker(
                        model: MapMarkerModel(
                            id: i,
                            time: '',
                            cost: '',
                            moreCnt: i % 2 == 0 ? 2 : 1,
                            latitude: 120,
                            longitude: 35))
                    .getMarker(context, selected: i > 1);
                cacheImageMarker.add(marker);
              }
              await controller.addOverlayAll(cacheImageMarker);
              _mapController = controller;
            },
          ),
        DraggableScrollableSheet(
          initialChildSize: 0.12,
          maxChildSize: 0.9,
          minChildSize: 0.12,
          snap: true,
          controller: _draggableScrollableController,
          builder: (BuildContext context, ScrollController scrollController) {
            final dateTime = DateTime.now();
            List<DateTime> dateTimes = [];
            final dateFormat = DateFormat('yyyy-MM-dd E', 'ko');
            for (int i = 0; i < 14; i++) {
              dateTimes.add(dateTime.add(Duration(days: i)));
            }
            final day = dateTimes.map((e) {
              return dateFormat.format(e).split(' ');
            }).toList();
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r))),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: 7.h),
                        Container(
                          height: 4.h,
                          width: 60.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD9D9D9),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Row(
                              children: [
                                ...day.mapIndexed((idx, element) {
                                  return Row(
                                    children: [
                                      DateBox(
                                        day: DateTime.parse(day[idx][0]),
                                        dayOfWeek: day[idx][1],
                                      ),
                                      if (idx != day.length - 1)
                                        SizedBox(width: 16.w),
                                    ],
                                  );
                                })
                              ],
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   height: 60.h,
                        //   child: ListView.separated(
                        //       padding: EdgeInsets.symmetric(horizontal: 12.w),
                        //       scrollDirection: Axis.horizontal,
                        //       shrinkWrap: true,
                        //       itemBuilder: (_, idx) {
                        //         return DateBox(
                        //           day: DateTime.parse(day[idx][0]),
                        //           dayOfWeek: day[idx][1],
                        //         );
                        //       },
                        //       separatorBuilder: (_, idx) {
                        //         return SizedBox(width: 16.w);
                        //       },
                        //       itemCount: day.length),
                        // ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 14.h),
                  ),
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final modelList = ref.watch(selectGameListProvider);
                      // ref.listen(gameListProvider, (previous, next) {
                      //   if (next is ResponseListModel<GameModel>) {
                      //     ref
                      //         .read(selectGameListProvider.notifier)
                      //         .update((state) => next.data!);
                      //   }
                      // });

                      return SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 21.w),
                        sliver: SliverMainAxisGroup(slivers: [
                          SliverToBoxAdapter(
                            child: Text(
                              '${modelList.length}개의 매치',
                              style: MITITextStyle.selectionDayStyle.copyWith(
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ),
                          _getCourtComponent(modelList),
                        ]),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }

  Widget _getCourtComponent(List<GameModel> modelList) {
    if (modelList.isEmpty) {
      return SliverToBoxAdapter(
          child: Column(
        children: [
          SizedBox(height: 12.h),
          SvgPicture.asset(
            'assets/images/icon/system_alert.svg',
            height: 70.r,
            width: 70.r,
            colorFilter:
                const ColorFilter.mode(Color(0xFF999999), BlendMode.srcIn),
          ),
          SizedBox(height: 24.h),
          Text(
            '경기가 없습니다.\n경기를 직접 호스팅해보세요!',
            style: MITITextStyle.pageSubTextStyle
                .copyWith(color: const Color(0xFF999999)),
            textAlign: TextAlign.center,
          )
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
      final fee = NumberFormat.decimalPattern().format(model.fee);

      markerList.add(MapMarkerModel(
          time:
              '${model.starttime.substring(0, 5)}-${model.endtime.substring(0, 5)}',
          cost: '₩$fee',
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
  final CourtModel court;
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
    final fee = NumberFormat.decimalPattern().format(model.fee);
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
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE8E8E8))),
        padding: EdgeInsets.all(8.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameStateLabel(gameStatus: game_status),
                  SizedBox(height: 3.h),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MITITextStyle.gameTitleMainStyle.copyWith(
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${starttime.substring(0, 5)} ~ ${endtime.substring(0, 5)}',
                    style: MITITextStyle.gameTimeCardMStyle.copyWith(
                      color: const Color(0xFF999999),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/images/icon/people.svg'),
                          SizedBox(width: 5.w),
                          Text(
                            '$num_of_participations/$max_invitation',
                            style:
                                MITITextStyle.participationCardStyle.copyWith(
                              color: const Color(0xFF444444),
                            ),
                          )
                        ],
                      ),
                      Text(
                        '₩$fee',
                        textAlign: TextAlign.right,
                        style: MITITextStyle.feeStyle.copyWith(
                          color: const Color(0xFF4065F6),
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

  const DateBox({super.key, required this.day, required this.dayOfWeek});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectDay = day.day;
    final selectedDay = ref.watch(selectedDayProvider);
    final textStyle = MITITextStyle.selectionDayStyle.copyWith(
      color: selectedDay == day ? Colors.white : const Color(0xFF707070),
    );
    return InkWell(
      onTap: () {
        ref.read(selectedDayProvider.notifier).update((state) => day);
      },
      child: Container(
        width: 60.w,
        // height: 52.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: selectedDay == day
              ? const Color(0xFF4065F6)
              : const Color(0xFFF2F2F2),
        ),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Text(
              '$selectDay',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
            SizedBox(height: 4.h),
            Text(
              dayOfWeek,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
