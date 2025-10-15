import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_drop_down_button.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/court/provider/court_pagination_provider.dart';
import 'package:miti/court/provider/widget/court_search_provider.dart';
import 'package:miti/court/view/court_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/dispose_sliver_cursor_pagination_list_view.dart';
import '../../common/component/sliver_delegate.dart';
import '../component/court_search_card.dart';
import '../component/skeleton/court_list_skeleton.dart';
import '../model/v2/court_map_response.dart';
import 'court_map_screen.dart';

class CourtSearchListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'courtSearch';

  const CourtSearchListScreen({
    super.key,
  });

  @override
  ConsumerState<CourtSearchListScreen> createState() =>
      _CourtSearchScreenState();
}

class _CourtSearchScreenState extends ConsumerState<CourtSearchListScreen> {
  late final ScrollController controller;
  final SliverOverlapAbsorberHandle _firstHandle =
      SliverOverlapAbsorberHandle();
  final SliverOverlapAbsorberHandle _secondHandle =
      SliverOverlapAbsorberHandle();

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((s) {
      ref.read(scrollControllerProvider.notifier).update((s) => controller);
    });
  }

  Future<void> refresh() async {
    final form = ref.read(courtSearchProvider);
    ref.read(courtPageProvider(PaginationStateParam()).notifier).paginate(
        cursorPaginationParams: const CursorPaginationParam(),
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
    return SafeArea(
      child: NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder:
              ((BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: _firstHandle,
                sliver: const DefaultAppBar(
                  isSliver: true,
                  title: '경기장 조회',
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
                          onChanged: searchCourt,
                          selectRegion: selectRegion, placeholder: '경기장 (주소/경기장 명)을 검색해주세요',
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
                        padding: EdgeInsets.only(
                            left: 21.w, right: 21.w, bottom: 20.h),
                        sliver: SliverMainAxisGroup(slivers: [
                          Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              final form = ref.watch(courtSearchProvider);

                              return DisposeSliverCursorPaginationListView(
                                provider:
                                    courtPageProvider(PaginationStateParam()),
                                itemBuilder: (BuildContext context, int index,
                                    Base model) {
                                  model as CourtMapResponse;
                                  return ResultCard.fromModel(
                                    model: model,
                                    onTap: () {
                                      onTap(model, context);
                                    },
                                  );
                                },
                                param: form,
                                skeleton: const CourtListSkeleton(),
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
    );
  }

  void selectRegion(String? region) {
    final district =
        region == '지역' ? null : DistrictType.stringToEnum(value: region!);
    final form = ref
        .read(courtSearchProvider.notifier)
        .update(district: district, isAll: district == null);
    ref
        .read(dropDownValueProvider(DropButtonType.district).notifier)
        .update((state) => region);
    ref.read(courtPageProvider(PaginationStateParam()).notifier).paginate(
        cursorPaginationParams: const CursorPaginationParam(),
        forceRefetch: true,
        param: form);
  }

  void searchCourt(val) {
    final form = ref.read(courtSearchProvider.notifier).update(search: val);
    ref
        .read(courtPageProvider(PaginationStateParam()).notifier)
        .updateDebounce(param: form);
  }

  void onTap(CourtMapResponse model, BuildContext context) {
    Map<String, String> pathParameters = {'courtId': model.id.toString()};
    context.pushNamed(
      CourtDetailScreen.routeName,
      pathParameters: pathParameters,
    );
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '조회된 경기장이 없습니다.',
          style: MITITextStyle.xxl140.copyWith(color: Colors.white),
        ),
        SizedBox(height: 20.h),
        Text(
          '검색어와 필터를 변경해 다른 경기를 찾아보세요!',
          style: MITITextStyle.sm.copyWith(color: MITIColor.gray300),
        )
      ],
    );
  }
}

typedef SelectRegion = void Function(String? region);

class SearchComponent extends StatefulWidget {
  final String placeholder;
  final ValueChanged<String> onChanged;
  final SelectRegion selectRegion;

  const SearchComponent({
    super.key,
    required this.onChanged,
    required this.selectRegion,
    required this.placeholder,
  });

  @override
  State<SearchComponent> createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  String region = '지역';
  final items = [
    '지역',
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '광주',
    '대전',
    '울산',
    '세종',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 20.h, bottom: 10.h),
      child: Row(
        children: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              // final form = ref.watch(courtSearchProvider);
              return Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    constraints:
                        BoxConstraints.loose(Size(double.infinity, 100.h)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(100.r)),
                    hintText: widget.placeholder,
                    hintStyle: MITITextStyle.xxsmSemiBold.copyWith(
                      height: 1,
                      color: MITIColor.gray500,
                    ),
                    fillColor: MITIColor.gray700,
                    isDense: true,
                  ),
                  style: MITITextStyle.xxsmSemiBold.copyWith(
                    color: MITIColor.gray100,
                    height: 1,
                  ),
                  onChanged: widget.onChanged,
                  //     (val) {
                  //   final form = ref
                  //       .read(courtSearchProvider.notifier)
                  //       .update(search: val);
                  //   ref
                  //       .read(
                  //           courtPageProvider(PaginationStateParam()).notifier)
                  //       .updateDebounce(param: form);
                  // }
                  // ,
                  onFieldSubmitted: (val) {
                    // ref.read(courtSearchProvider.notifier).search(page: 1);
                  },
                ),
              );
            },
          ),
          SizedBox(width: 8.w),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return GestureDetector(
                onTap: () {
                  String selectRegion = region;
                  showModalBottomSheet(
                      isScrollControlled: true,
                      useRootNavigator: true,
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.r),
                        ),
                      ),
                      backgroundColor: MITIColor.gray800,
                      builder: (context) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter localSetState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: MITIColor.gray100,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  width: 60.w,
                                  height: 4.h,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(20.r),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '지역',
                                      style: MITITextStyle.mdBold.copyWith(
                                        color: MITIColor.gray100,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Wrap(
                                      spacing: 10.r,
                                      runSpacing: 10.r,
                                      children: items
                                          .map((r) => GestureDetector(
                                                onTap: () {
                                                  localSetState(() {
                                                    if (selectRegion == r) {
                                                      selectRegion = '';
                                                    } else {
                                                      selectRegion = r;
                                                    }
                                                  });
                                                },
                                                child: RegionCard(
                                                  isSelected: selectRegion == r,
                                                  region: r,
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                    SizedBox(height: 20.h),
                                    TextButton(
                                        onPressed: selectRegion.isNotEmpty
                                            ? () {
                                                widget
                                                    .selectRegion(selectRegion);
                                                context.pop();
                                                FocusScope.of(context)
                                                    .unfocus();
                                                setState(() {
                                                  region = selectRegion;
                                                  log(region);
                                                });
                                              }
                                            : null,
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                selectRegion.isNotEmpty
                                                    ? MITIColor.primary
                                                    : MITIColor.gray500),
                                        child: Text(
                                          '확인',
                                          style: MITITextStyle.mdBold.copyWith(
                                              color: selectRegion.isNotEmpty
                                                  ? MITIColor.gray800
                                                  : MITIColor.gray50),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          );
                        });
                      });
                },
                child: Container(
                  width: 77.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.r),
                    color: MITIColor.gray700,
                  ),
                  padding: EdgeInsets.only(left: 16.w, right: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        region,
                        style: MITITextStyle.xxsmLight
                            .copyWith(color: MITIColor.gray100),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: MITIColor.primary,
                        size: 16.r,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RegionCard extends StatelessWidget {
  final String region;
  final bool isSelected;

  const RegionCard({super.key, required this.region, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 103.w,
      height: 48.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
            color: isSelected ? MITIColor.primary : MITIColor.gray800),
        color: MITIColor.gray750,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            region,
            style: MITITextStyle.sm.copyWith(
              color: MITIColor.gray100,
            ),
          )
        ],
      ),
    );
  }
}
