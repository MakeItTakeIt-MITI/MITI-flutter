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
import 'package:intl/intl.dart';
import 'package:miti/court/component/court_component.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';

import '../../common/model/entity_enum.dart';

final makerProvider = StateProvider.autoDispose((ref) => [0, 1, 2, 3, 4, 5, 6]);
final selectMakerProvider = StateProvider.autoDispose<int?>((ref) => null);
final draggableScrollController = StateProvider.autoDispose<ScrollController?>((ref) => null);

class CourtMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'home';

  const CourtMapScreen({
    super.key,
  });

  @override
  ConsumerState<CourtMapScreen> createState() => _HomeScreenState();
}

final positionProvider = StateProvider<Position?>((ref) => null);

class _HomeScreenState extends ConsumerState<CourtMapScreen> {
  late final DraggableScrollableController _draggableScrollableController;

  @override
  void initState() {
    super.initState();
    _draggableScrollableController = DraggableScrollableController();

    _permission();
    getLocation();
  }

  void _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    if (requestStatus.isGranted && status.isLimited) {
      // isLimited - 제한적 동의 (ios 14 < )
      // 요청 동의됨
      print("isGranted");
      if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
        // 요청 동의 + gps 켜짐
        var position = await Geolocator.getCurrentPosition();
        print("serviceStatusIsEnabled position = ${position.toString()}");
      } else {
        // 요청 동의 + gps 꺼짐
        print("serviceStatusIsDisabled");
      }
    } else if (requestStatus.isPermanentlyDenied ||
        status.isPermanentlyDenied) {
      // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
      print("isPermanentlyDenied");
      openAppSettings();
    } else if (status.isRestricted) {
      // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
      print("isRestricted");
      openAppSettings();
    } else if (status.isDenied) {
      // 권한 요청 거절
      print("isDenied");
    }
    print("requestStatus ${requestStatus.name}");
    print("status ${status.name}");
  }

  void getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      ref.read(positionProvider.notifier).update((state) => position);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(positionProvider);
    final select = ref.watch(selectMakerProvider);
    log('position = ${position}');
    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(37.5666, 126.979),
              zoom: 15,
            ),
            locale: Locale('ko'),
          ),
          onSymbolTapped: (NSymbolInfo symbolInfo) {
            log('${symbolInfo}');
            log('${symbolInfo.position}');
            log('${symbolInfo.caption}');
          },
          onMapReady: (controller) async {
            print("네이버 맵 로딩됨!");
            final markerList = ref.read(makerProvider);
            final List<MapMarkerModel> modelList = markerList
                .map((e) => MapMarkerModel(
                    time: '15:00-18:00',
                    cost: '₩${e}0,0000',
                    moreCnt: 88,
                    id: e,
                    latitude: 37.5666 + e * 0.01,
                    longitude: 126.979))
                .toList();

            final customMarkerList =
                modelList.map((e) => CustomMarker(model: e)).toList();
            final futureMarkerList = modelList
                .map((e) => CustomMarker(model: e).getMarker(context))
                .toList();

            for (int i = 0; i < futureMarkerList.length; i++) {
              final marker = await futureMarkerList[i];

              marker.setOnTapListener((NMarker overlay) async {
                _draggableScrollableController.animateTo(0.9, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, );

                await controller.updateCamera(NCameraUpdate.fromCameraPosition(
                    NCameraPosition(
                        target: NLatLng(37.5666 + i * 0.01, 126.979),
                        zoom: 15)));
                for (int j = 0; j < futureMarkerList.length; j++) {
                  final compareMarker = await futureMarkerList[j];

                  if (marker.info.id != compareMarker.info.id) {
                    ///선택 해제 마커
                    final findMarker = customMarkerList.firstWhere(
                        (e) => e.model.id.toString() == compareMarker.info.id);
                    if (context.mounted) {
                      final value = await findMarker.getNOverlayImage(context);
                      compareMarker.setIcon(value);
                    }
                  }
                }

                final findMarker = customMarkerList
                    .firstWhere((e) => e.model.id.toString() == marker.info.id);

                /// 선택된 마커
                if (context.mounted) {
                  final value = await findMarker.getNOverlayImage(context, selected: true);
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
            await controller.addOverlayAll(allOverlay);

            // final futureMarkers = markerList.mapIndexed((idx, e) async {
            //   return await NOverlayImage.fromWidget(
            //       widget: SpeechBubble(
            //         model: MapMarkerModel(
            //             time: '15:00-18:00',
            //             cost: '₩10,0000',
            //             moreCnt: 88,
            //             id: idx,
            //             latitude: 37.5666 + e * 0.01,
            //             longitude: 126.979),
            //         selected: false,
            //       ),
            //       size: Size(
            //         140.w,
            //         80.h,
            //       ),
            //       context: context);
            // }).toList();
            //
            // final List<Future<NMarker>> overlay = markerList.map((e) async {
            //   final icon = await futureMarkers[e];
            //   final marker = NMarker(
            //       id: '$e',
            //       position: NLatLng(37.5666 + e * 0.01, 126.979),
            //       icon: icon);
            //
            //   return NMarker(
            //       id: '$e',
            //       position: NLatLng(37.5666 + e * 0.01, 126.979),
            //       icon: icon)
            //     ..setOnTapListener((NMarker overlay) async {
            //       final unselect = ref.read(selectMakerProvider);
            //       if (unselect != null) {
            //         await controller.deleteOverlay(NOverlayInfo(
            //             type: NOverlayType.marker, id: '$unselect'));
            //
            //         final unselectedMarker = await NOverlayImage.fromWidget(
            //             widget: SpeechBubble(
            //               model: MapMarkerModel(
            //                   time: '15:00-18:00',
            //                   cost: '₩10,000',
            //                   moreCnt: 88,
            //                   id: unselect,
            //                   latitude: 0,
            //                   longitude: 0),
            //               selected: false,
            //             ),
            //             size: Size(
            //               140.w,
            //               80.h,
            //             ),
            //             context: context);
            //         await controller.addOverlay(NMarker(
            //             id: '$unselect',
            //             position: NLatLng(37.5666 + unselect * 0.01, 126.979),
            //             icon: unselectedMarker));
            //       }
            //
            //       ref.read(selectMakerProvider.notifier).update((state) => e);
            //
            //       await controller.deleteOverlay(
            //           NOverlayInfo(type: NOverlayType.marker, id: '$e'));
            //       final selectedMarker = await NOverlayImage.fromWidget(
            //           widget: SpeechBubble(
            //             model: MapMarkerModel(
            //                 time: '15:00-18:00',
            //                 cost: '₩10,000',
            //                 moreCnt: 88,
            //                 id: e,
            //                 latitude: 0,
            //                 longitude: 0),
            //             selected: true,
            //           ),
            //           size: Size(
            //             140.w,
            //             80.h,
            //           ),
            //           context: context);
            //       await controller.addOverlay(NMarker(
            //           id: '$e',
            //           position: NLatLng(37.5666 + e * 0.01, 126.979),
            //           icon: selectedMarker));
            //     });
            // }).toList();
            //
            // overlay.mapIndexed((e, element) async {
            //   final marker = await element;
            //   marker.setOnTapListener((element) async {
            //     log('tap element');
            //     await controller.updateCamera(NCameraUpdate.fromCameraPosition(
            //         NCameraPosition(
            //             target: NLatLng(37.5666 + e * 0.01, 126.979),
            //             zoom: 15)));
            //     final value = await NOverlayImage.fromWidget(
            //         widget: SpeechBubble(
            //           model: MapMarkerModel(
            //               time: '15:00-18:00',
            //               cost: '₩10,000',
            //               moreCnt: 88,
            //               id: e,
            //               latitude: 0,
            //               longitude: 0),
            //           selected: true,
            //         ),
            //         size: Size(
            //           140.w,
            //           80.h,
            //         ),
            //         context: context);
            //     for (int i = 0; i < 7; i++) {
            //       final m = await overlay[i];
            //       if (m != element) {
            //         final value = await NOverlayImage.fromWidget(
            //             widget: SpeechBubble(
            //               model: MapMarkerModel(
            //                   time: '15:00-18:00',
            //                   cost: '₩10,000',
            //                   moreCnt: 88,
            //                   id: i,
            //                   latitude: 0,
            //                   longitude: 0),
            //               selected: false,
            //             ),
            //             size: Size(
            //               140.w,
            //               80.h,
            //             ),
            //             context: context);
            //         m.setIcon(value);
            //       }
            //     }
            //
            //     element.setIcon(value);
            //   });
            // });
            //
            // final Set<NMarker> insertOverlay = {};
            // for (var o in overlay) {
            //   final m = await o;
            //   insertOverlay.add(m);
            // }
            // await controller.addOverlayAll(insertOverlay);
          },
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.15,
          maxChildSize: 0.9,
          minChildSize: 0.15,
          snap: true,
          controller: _draggableScrollableController,
          builder: (BuildContext context, ScrollController scrollController) {

            final dateTime = DateTime.now();
            List<DateTime> dateTimes = [];
            final dateFormat = DateFormat('dd E', 'ko');
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
                        SizedBox(
                          height: 60.h,
                          child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (_, idx) {
                                return DateBox(
                                  day: int.parse(day[idx][0]),
                                  dayOfWeek: day[idx][1],
                                );
                              },
                              separatorBuilder: (_, idx) {
                                return SizedBox(width: 16.w);
                              },
                              itemCount: day.length),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 25.h),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 21.w),
                    sliver: SliverMainAxisGroup(slivers: [
                      SliverToBoxAdapter(
                        child: Text(
                          '16개의 매치',
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.25,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        sliver: SliverList.separated(
                          itemBuilder: (_, idx) {
                            return CourtCard(
                              gameStatus: GameStatus.open,
                            );
                          },
                          separatorBuilder: (_, idx) {
                            return SizedBox(height: 12.h);
                          },
                          itemCount: 3,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}

class CourtCard extends StatelessWidget {
  final GameStatus gameStatus;

  const CourtCard({super.key, required this.gameStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                GameStateLabel(gameStatus: gameStatus),
                SizedBox(height: 3.h),
                Text(
                  '수원 매탄 공원 4 vs 4 (주차 12자리)수원 매탄 공원 4 vs 4 (주차 12자리)수원 매탄 공원 4 vs 4 (주차 12자리)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '15:30~ 18:00 ',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12.sp,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.25,
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
                          '15/18',
                          style: TextStyle(
                            color: const Color(0xFF444444),
                            fontSize: 12.sp,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.25,
                          ),
                        )
                      ],
                    ),
                    Text(
                      '₩23,000',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF4065F6),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
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

final selectedDayProvider =
    StateProvider.autoDispose<int>((ref) => DateTime.now().day);

class DateBox extends ConsumerWidget {
  final int day;
  final String dayOfWeek;

  const DateBox({super.key, required this.day, required this.dayOfWeek});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final textStyle = TextStyle(
      color: selectedDay == day ? Colors.white : const Color(0xFF707070),
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.25,
    );
    return InkWell(
      onTap: () {
        ref.read(selectedDayProvider.notifier).update((state) => day);
      },
      child: Container(
        width: 60.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: selectedDay == day
              ? const Color(0xFF4065F6)
              : const Color(0xFFF2F2F2),
        ),
        child: Column(
          children: [
            SizedBox(height: 8.5.h),
            Text(
              '$day',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
            SizedBox(height: 4.h),
            Text(
              dayOfWeek,
              textAlign: TextAlign.center,
              style: textStyle,
            )
          ],
        ),
      ),
    );
  }
}
