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
import 'package:miti/court/view/court_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../component/court_search_card.dart';
import '../model/court_model.dart';

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
    return NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
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
                padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
                sliver: SliverMainAxisGroup(slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: _SearchComponent()),
                        SizedBox(height: 20.h),
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
        ));
  }

  void onTap(CourtSearchModel model, BuildContext context) {
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
    '전체',
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
                  filled: true,
                  constraints:
                      BoxConstraints.loose(Size(double.infinity, 100.h)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(100.r)),
                  hintText: '경기장 (주소/경기장 명)을 검색해주세요',
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
        SizedBox(width: 8.w),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return CustomDropDownButton(
              initValue: '전체',
              items: items,
              onChanged: (val) {
                changeDropButton(val, ref);
              },
              type: DropButtonType.district,
            );
          },
        ),
      ],
    );
  }

  void changeDropButton(String? val, WidgetRef ref) {
    final district =
        val == '전체' ? null : DistrictType.stringToEnum(value: val!);
    final form = ref
        .read(courtSearchProvider.notifier)
        .update(district: district, isAll: district == null);
    ref
        .read(dropDownValueProvider(DropButtonType.district).notifier)
        .update((state) => val);
    ref.read(courtPageProvider(PaginationStateParam()).notifier).paginate(
        paginationParams: const PaginationParam(page: 1),
        forceRefetch: true,
        param: form);
  }
}
