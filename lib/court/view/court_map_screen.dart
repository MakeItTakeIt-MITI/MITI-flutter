import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/component/picker/custom_time_picker.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/component/court_component.dart';
import 'package:miti/game/param/game_param.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_filter_provider.dart';
import 'package:miti/game/view/game_search_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../../common/model/entity_enum.dart';
import '../../game/component/game_card.dart';
import '../../game/model/game_model.dart';
import '../../game/model/v2/game/game_with_court_map_response.dart';
import '../../game/view/game_detail_screen.dart';

final selectGameListProvider =
    StateProvider.autoDispose<List<GameWithCourtMapResponse>>((ref) => []);
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
  final ScrollController listViewController = ScrollController();
  final SnappingSheetController snappingSheetController =
      SnappingSheetController();
  NaverMapController? _mapController;
  late final Box<bool> permissionBox;

  @override
  bool get wantKeepAlive => true; //override with True.
  @override
  void initState() {
    super.initState();
    log('page init!!');
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
    _mapController?.dispose();
    listViewController.dispose();
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
        snappingSheetController
            .snapToPosition(const SnappingPosition.factor(positionFactor: 0));
      }
    });

    // log('page build!!');
    final position = ref.watch(positionProvider);
    final select = ref.watch(selectMakerProvider);

    ref.listen(mapGameListProvider, (previous, next) {
      log("listen mapGameListProvider");
      if (_mapController != null) {
        if (next is LoadingModel) {
        } else if (next is ErrorModel) {
        } else {
          refreshMarker(next);
        }
      }
    });

    return SnappingSheet(
      controller: snappingSheetController,
      lockOverflowDrag: true,
      snappingPositions: const [
        SnappingPosition.factor(
          positionFactor: 0,
          snappingDuration: Duration(milliseconds: 300),
          grabbingContentOffset: GrabbingContentOffset.middle,
        ),
        SnappingPosition.factor(
          grabbingContentOffset: GrabbingContentOffset.bottom,
          snappingDuration: Duration(milliseconds: 300),
          positionFactor: 0.85,
        ),
      ],
      grabbing: const GrabbingWidget(),
      initialSnappingPosition: const SnappingPosition.factor(positionFactor: 0),
      grabbingHeight: 60.h,
      sheetAbove: null,
      sheetBelow: SnappingSheetContent(
        draggable: true,
        childScrollController: listViewController,
        child: Container(
          color: V2MITIColor.gray12,
          child: CustomScrollView(
            controller: listViewController,
            slivers: [
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final modelList = ref.watch(selectGameListProvider);
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: _getCourtComponent(modelList),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      child: CourtMapBackground(
        position: position,
        onMapReady: (controller) {
          _mapController = controller;
        },
        onTap: () async {
          if (position == null) {
            _permission();
          } else {
            ref.read(positionProvider.notifier).update((state) => null);
            await _mapController!
                .setLocationTrackingMode(NLocationTrackingMode.none);
          }
        },
      ),
    );
  }

  Widget _getCourtComponent(List<GameWithCourtMapResponse> modelList) {
    if (modelList.isEmpty) {
      return SliverToBoxAdapter(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 250.h),
          Text(
            '아직 생성된 경기가 없습니다.',
            style: V2MITITextStyle.regularMediumNormal
                .copyWith(color: V2MITIColor.gray7),
            textAlign: TextAlign.center,
          ),
        ],
      ));
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      sliver: SliverList.separated(
        itemBuilder: (_, idx) {
          return GameCard.fromModel(model: modelList[idx]);
        },
        separatorBuilder: (_, idx) {
          return Divider(
            color: V2MITIColor.gray10,
            height: 16.h,
            thickness: 1.h,
          );
        },
        itemCount: modelList.length,
      ),
    );
  }

  void refreshMarker(BaseModel response) async {
    // log('refreshMarker');
    final model =
        (response as ResponseListModel<GameWithCourtMapResponse>).data!;
    Map<MapPosition, List<GameWithCourtMapResponse>> markers = {};

    for (GameWithCourtMapResponse value in model) {
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
      final GameWithCourtMapResponse model = markers[key]!.first;
      final fee = model.fee == 0
          ? "무료 경기"
          : '₩${NumberFormat.decimalPattern().format(model.fee)}';

      markerList.add(MapMarkerModel(
          time: '${model.startTime.substring(0, 5)}~',
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

        snappingSheetController.snapToPosition(
            const SnappingPosition.factor(positionFactor: 0.85));
        // _draggableScrollableController.animateTo(
        //   0.9,
        //   duration: const Duration(milliseconds: 500),
        //   curve: Curves.easeInOut,
        // );

        await _mapController?.updateCamera(NCameraUpdate.fromCameraPosition(
            NCameraPosition(
                target: NLatLng(
                    overlay.position.latitude, overlay.position.longitude),
                zoom: 13)));
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
        ref.watch(gameFilterProvider(routeName: CourtMapScreen.routeName).select((value) => value.startdate));

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
                    ? V2MITIColor.red5
                    : isSelect
                        ? MITIColor.gray100
                        : V2MITIColor.gray7,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 32.r,
              width: 32.r,
              decoration: isSelect
                  ? const BoxDecoration(
                      shape: BoxShape.circle,
                      color: V2MITIColor.primary5,
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                '$selectDay',
                style: V2MITITextStyle.smallBold.copyWith(
                  color: isSelect ? V2MITIColor.black : V2MITIColor.gray7,
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
      joinFilter = ref.read(gameFilterProvider(routeName: CourtMapScreen.routeName));
      final time = joinFilter.starttime!.split(':');
      final hour = int.parse(time[0]);
      final min = int.parse(time[1]);
      timePeriodController.jumpToItem(hour >= 12 ? 1 : 0);
      hourController.jumpToItem(hour % 12);
      minController.jumpToItem(min ~/ 10);
    });
  }

  void selectDay(List<List<String>> day, int idx) {
    ref.read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier).update(startdate: day[idx][0]);
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
    final startdateByString = ref.watch(
        gameFilterProvider(routeName: CourtMapScreen.routeName)
            .select((value) => value.startdate));
    final selectedMonth = startdateByString != null
        ? DateTime.parse(startdateByString).month
        : DateTime.now().month;

    return Container(
      color: V2MITIColor.gray12,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12.h,
          children: [
            const _FilterChipsComponent(
              inFilter: true,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                spacing: 12.h,
                children: [
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                "날짜",
                                style: V2MITITextStyle.smallBoldTight.copyWith(
                                  color: V2MITIColor.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          SingleChildScrollView(
                            controller: _dayScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...day.mapIndexed((idx, element) {
                                  final date = day[idx][0].split('-');
                                  final month =
                                      date[1][0] == '0' ? date[1][1] : date[1];

                                  final bool showYear =
                                      month == '1' && date[2] == '01';
                                  final bool showMonth =
                                      date[2] == '01' || idx == 0;
                                  return Row(
                                    children: [
                                      if (showMonth)
                                        Padding(
                                          padding: EdgeInsets.only(right: 16.w),
                                          child: Column(
                                            children: [
                                              if (showYear)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5.h),
                                                  child: Text(
                                                    date[0],
                                                    style: V2MITITextStyle
                                                        .tinyRegular
                                                        .copyWith(
                                                      color:
                                                          V2MITIColor.primary5,
                                                    ),
                                                  ),
                                                ),
                                              Text(
                                                "$month월",
                                                style: V2MITITextStyle.smallBold
                                                    .copyWith(
                                                        color: V2MITIColor
                                                            .primary5),
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
                      );
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "경기 시작 시간",
                        style: V2MITITextStyle.smallBoldTight.copyWith(
                          color: V2MITIColor.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 38.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                  height: 90.h,
                                  child: CustomTimePicker(
                                    timePeriodController: timePeriodController,
                                    hourController: hourController,
                                    minController: minController,
                                  )),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "이후 경기",
                              style: V2MITITextStyle.tinyMediumTight
                                  .copyWith(color: V2MITIColor.white),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "경기 상태",
                        style: V2MITITextStyle.smallBoldTight
                            .copyWith(color: V2MITIColor.white),
                      ),
                      SizedBox(height: 12.h),
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          final chipGameStatus = GameStatusType.values
                              .where(
                                  (status) => status != GameStatusType.canceled)
                              .toList();
                          final selectedGameStatus = ref.watch(
                              gameFilterProvider(routeName: CourtMapScreen.routeName)
                                  .select((value) => value.gameStatus));

                          return Row(
                            spacing: 6.w,
                            children: chipGameStatus
                                .map((e) => _GameStatusButton(
                                    status: e,
                                    selected: selectedGameStatus.isNotEmpty
                                        ? selectedGameStatus.contains(e)
                                        : false))
                                .toList(),
                          );
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      TextButton(
                          onPressed: filterClear,
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      side: const BorderSide(
                                        color: V2MITIColor.gray6,
                                      ))),
                              backgroundColor: WidgetStateProperty.all(
                                V2MITIColor.gray12,
                              ),
                              minimumSize:
                                  WidgetStateProperty.all(Size(98.w, 48.h)),
                              maximumSize:
                                  WidgetStateProperty.all(Size(98.w, 48.h)),
                              fixedSize:
                                  WidgetStateProperty.all(Size(98.w, 48.h))),
                          child: Text(
                            "초기화",
                            style: V2MITITextStyle.regularBold
                                .copyWith(color: V2MITIColor.gray6),
                          )),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextButton(
                            onPressed: () {
                              ref.read(mapGameListProvider.notifier).getList();
                              ref
                                  .read(showFilterProvider.notifier)
                                  .update((state) => false);
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                V2MITIColor.primary5,
                              ),
                            ),
                            child: Text(
                              "적용하기",
                              style: V2MITITextStyle.regularBold
                                  .copyWith(color: V2MITIColor.gray12),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// todo 수정 필요
            GestureDetector(
              onTap: () {
                ref.read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier).rollback(joinFilter);
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
    ref.read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier).clear();
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
  final GameStatusType status;
  final bool selected;

  const _GameStatusButton(
      {super.key, required this.status, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final filterStatus = ref.read(gameFilterProvider(routeName: CourtMapScreen.routeName)).gameStatus;
        //선택 된 상태면 선택 해제
        if (selected) {
          log("선택 된 상태면 선택 해제");
          ref.read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier).deleteStatus(status);
        } else {
          if (filterStatus.isNotEmpty) {
            // 하나 이상 선택된 상태
            log("하나 이상 선택된 상태");
            ref.read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier).addStatus(status);
          } else {
            //아무것도 선택 안된 상태
            log("아무것도 선택 안된 상태");
            ref.read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier).initStatus(status);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: selected ? V2MITIColor.primary5 : Colors.transparent,
            border: Border.all(
              color: selected ? V2MITIColor.primary5 : V2MITIColor.gray8,
            ),
            borderRadius: BorderRadius.circular(50.r)),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Text(
          status.displayName,
          style: V2MITITextStyle.tinyMedium.copyWith(
            color: selected ? V2MITIColor.black : V2MITIColor.gray5,
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
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
                color: inFilter ? V2MITIColor.gray11 : Colors.transparent),
            color: inFilter ? V2MITIColor.gray12 : V2MITIColor.black),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            Text(
              title,
              style: selected
                  ? V2MITITextStyle.smallMediumTight
                      .copyWith(color: V2MITIColor.primary5)
                  : V2MITITextStyle.tinyMedium.copyWith(
                      color: inFilter ? MITIColor.gray100 : MITIColor.gray50),
            ),
            if (selected && inFilter)
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: GestureDetector(
                  onTap: onTap,
                  child: SvgPicture.asset(
                    AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: 'close2',
                    ),
                    colorFilter: const ColorFilter.mode(
                        V2MITIColor.primary5, BlendMode.srcIn),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      scrollDirection: Axis.horizontal,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final filter = ref.watch(gameFilterProvider(routeName: CourtMapScreen.routeName));

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
                      .read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier)
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
                      .read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier)
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
                      .read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier)
                      .removeFilter(FilterType.status);
                },
                inFilter: inFilter,
              ),
              // todo 지역 필터칩 추가
              // _FilterChip(
              //   title: gameStatus.isEmpty ? '지역' : province,
              //   selected: filter.gameStatus.isNotEmpty,
              //   onTap: () {
              //     ref
              //         .read(gameFilterProvider(routeName: CourtMapScreen.routeName).notifier)
              //         .removeFilter(FilterType.status);
              //   },
              //   inFilter: inFilter,
              // ),
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

class CourtMapBackground extends ConsumerWidget {
  final Position? position;
  final Function(NaverMapController controller) onMapReady;
  final VoidCallback onTap;

  const CourtMapBackground({
    super.key,
    this.position,
    required this.onMapReady,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        NaverMap(
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(37.5666, 126.979),
              zoom: 13,
            ),
            locale: Locale('ko'),
          ),
          onMapTapped: (NPoint point, NLatLng latLng) {
            // print("tap point = $point latLng = $latLng");
            ref.read(showFilterProvider.notifier).update((state) => !state);
          },
          onMapReady: onMapReady,
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
                onTap: onTap,
                child: SvgPicture.asset(
                  AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: position != null ? "gps" : "un_gps"),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GrabbingWidget extends StatelessWidget {
  const GrabbingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: V2MITIColor.gray12,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 4.h,
              width: 140.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
                color: V2MITIColor.white,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Consumer(builder: (_, ref, child) {
            final modelList = ref.watch(selectGameListProvider);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 ${modelList.length} 경기',
                    style: V2MITITextStyle.smallBoldNormal.copyWith(
                      color: V2MITIColor.gray1,
                    ),
                  ),
                  InkWell(
                    child: Text(
                      '전체 경기',
                      style: V2MITITextStyle.tinyMediumNormal
                          .copyWith(color: V2MITIColor.white),
                    ),
                    onTap: () {
                      context.pushNamed(GameSearchScreen.routeName);
                    },
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
