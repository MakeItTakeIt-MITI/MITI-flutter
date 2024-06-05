import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_drop_down_button.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/court/param/court_pagination_param.dart';
import 'package:miti/court/provider/court_pagination_provider.dart';
import 'package:miti/court/provider/court_provider.dart';
import 'package:miti/court/provider/widget/court_search_provider.dart';
import 'package:miti/court/view/court_game_list_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../component/court_search_card.dart';
import '../model/court_model.dart';

class CourtSearchScreen extends ConsumerStatefulWidget {
  static String get routeName => 'courtSearch';
  final int bottomIdx;

  const CourtSearchScreen({
    super.key,
    required this.bottomIdx,
  });

  @override
  ConsumerState<CourtSearchScreen> createState() => _CourtSearchScreenState();
}

class _CourtSearchScreenState extends ConsumerState<CourtSearchScreen> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
  }

  Future<void> refresh() async {
    final form = ref.read(courtSearchProvider);
    ref.read(courtPageProvider(PaginationStateParam()).notifier).paginate(
        paginationParams: const PaginationParam(page: 1),
        param: form,
        forceRefetch: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      body: NestedScrollView(
          headerSliverBuilder:
              ((BuildContext context, bool innerBoxIsScrolled) {
            return [
              const DefaultAppBar(
                isSliver: true,
                title: '경기장 조회',
              ),
            ];
          }),
          body: RefreshIndicator(
            onRefresh: refresh,
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(14.r),
                  sliver: SliverMainAxisGroup(slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _SearchComponent(),
                          SizedBox(height: 14.h),
                        ],
                      ),
                    ),
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final form = ref.watch(courtSearchProvider);

                        return DisposeSliverPaginationListView(
                          provider: courtPageProvider(PaginationStateParam()),
                          itemBuilder:
                              (BuildContext context, int index, Base model) {
                            model as CourtSearchModel;
                            return ResultCard.fromModel(
                              model: model,
                              onTap: () {
                                onTap(model, context);
                              },
                            );
                          },
                          param: form,
                          skeleton: Container(),
                          controller: controller,
                          emptyWidget: getEmptyWidget(),
                        );
                      },
                    ),
                  ]),
                ),
              ],
            ),
          )),
      scrollController: controller,
    );
  }

  void onTap(CourtSearchModel model, BuildContext context) {
    Map<String, String> pathParameters = {'courtId': model.id.toString()};
    final Map<String, String> queryParameters = {'bottomIdx': '3'};
    final extra = model;
    context.pushNamed(
      CourtGameListScreen.routeName,
      pathParameters: pathParameters,
      extra: extra,
      queryParameters: queryParameters,
    );
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '검색 결과가 없습니다.',
          style: MITITextStyle.pageMainTextStyle,
        ),
        SizedBox(height: 20.h),
        Text(
          '다른 검색어로 경기장을 찾아보세요!',
          style: MITITextStyle.pageSubTextStyle,
        )
      ],
    );
  }
}

class _SearchComponent extends StatelessWidget {
  final items = [
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '광주',
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
    '대전',
    '전체 보기',
  ];

  _SearchComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            // final form = ref.watch(courtSearchProvider);
            return Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIconColor: const Color(0xFF969696),
                  suffixIcon: const Icon(
                    Icons.search,
                    // size: 16.r,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.r),
                  constraints: BoxConstraints(
                    maxHeight: 39.h,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: '경기장 검색어(주소 / 경기장 명)',
                  hintStyle: MITITextStyle.placeHolderMStyle.copyWith(
                    height: 1,
                    color: const Color(0xff969696),
                  ),
                  isDense: true,
                ),
                style: MITITextStyle.placeHolderMStyle.copyWith(
                  height: 1,
                ),
                onChanged: (val) {
                  final form = ref
                      .read(courtSearchProvider.notifier)
                      .update(search: val);
                  ref
                      .read(courtPageProvider(PaginationStateParam()).notifier)
                      .updateDebounce(param: form);
                },
                onFieldSubmitted: (val) {
                  // ref.read(courtSearchProvider.notifier).search(page: 1);
                },
              ),
            );
          },
        ),
        SizedBox(width: 12.w),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return CustomDropDownButton(
              initValue: '전체 보기',
              items: items,
              onChanged: (val) {
                changeDropButton(val, ref);
              },
            );
          },
        ),
      ],
    );
  }

  void changeDropButton(String? val, WidgetRef ref) {
    final district = DistrictType.stringToEnum(value: val!);
    final form = ref
        .read(courtSearchProvider.notifier)
        .update(district: district, isAll: district == null);
    ref.read(dropDownValueProvider.notifier).update((state) => val);
    ref.read(courtPageProvider(PaginationStateParam()).notifier).paginate(
        paginationParams: const PaginationParam(page: 1),
        forceRefetch: true,
        param: form);
  }
}
