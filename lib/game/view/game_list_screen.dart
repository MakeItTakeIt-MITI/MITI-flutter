import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/provider/scroll_provider.dart';
import 'package:miti/game/param/game_param.dart';
import 'package:miti/game/provider/game_provider.dart';

import '../../common/model/default_model.dart';
import '../component/game_list_component.dart';
import '../model/game_model.dart';

class GameParticipationScreen extends ConsumerStatefulWidget {
  static String get routeName => 'participation';

  const GameParticipationScreen({
    super.key,
  });

  @override
  ConsumerState<GameParticipationScreen> createState() =>
      _GameListScreenState();
}

class _GameListScreenState extends ConsumerState<GameParticipationScreen> {
  final List<String> items = [
    '모집중',
    '모집 완료',
    '경기 취소',
    '경기 완료',
    '전체 보기',
  ];
  String? selectedValue = '전체 보기';

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pageScrollControllerProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: controller[1],
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              title: '나의 참여 경기',
              isSliver: true,
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(right: 12.w, top: 12.h),
                child: Row(
                  children: [
                    const Spacer(),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        // isDense: true,
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 12.sp,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.25.sp,
                        ),
                        items: items
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    // style: TextStyle(
                                    //   color: Colors.red,
                                    //   fontSize: 12.sp,
                                    //   fontFamily: 'Pretendard',
                                    //   fontWeight: FontWeight.w500,
                                    //   letterSpacing: -0.25.sp,
                                    // ),
                                  ),
                                ))
                            .toList(),
                        value: selectedValue,
                        onChanged: (String? value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: const Color(0xFFF7F7F7)),
                          height: 32.h,
                          width: 85.w,
                        ),
                        iconStyleData: IconStyleData(
                            icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 16.r,
                        )),
                        dropdownStyleData: DropdownStyleData(
                            scrollPadding: EdgeInsets.zero,
                            width: 85.w,
                            elevation: 0,
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(4.r),
                                ),
                                color: const Color(0xFFF7F7F7))),
                        menuItemStyleData: MenuItemStyleData(
                          height: 30.h,
                          padding: EdgeInsets.zero,
                          overlayColor: MaterialStateProperty.all(Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(right: 12.w, left: 12.w, bottom: 12.h),
              sliver: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final param = GameListParam();
                  final response = ref.watch(gameListProvider);
                  if (response is LoadingModel) {
                    return SliverToBoxAdapter();
                  }
                  response as ResponseListModel<GameListByDateModel>;
                  final model = response.data!;
                  return SliverList.separated(
                    itemBuilder: (_, idx) {
                      return GameCardByDate.fromModel(
                        model: model[idx],
                      );
                    },
                    separatorBuilder: (_, idx) {
                      return SizedBox(height: 18.h);
                    },
                    itemCount: model.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
