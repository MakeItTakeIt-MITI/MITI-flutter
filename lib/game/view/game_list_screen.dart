import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  ConsumerState<GameParticipationScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends ConsumerState<GameParticipationScreen> {
  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final menuItems = ['전체 보기', '모집중', '모집 완료', '경기 취소', '경기 완료'];

    final controller = ref.watch(pageScrollControllerProvider);
    return Scaffold(
      body: NestedScrollView(
        controller: controller[1],
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              title: Text('나의 참여 경기',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000000),
                  )),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  const Spacer(),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      hint: Text(
                        'Select Item',
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff333333),
                          height: 14 / 12,
                        ),
                      ),

                      items: items
                          .map((String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff969696),
                                    height: 14 / 12,
                                  ),
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
                        // width: 140,
                      ),
                      iconStyleData : IconStyleData(icon: Icon(Icons.keyboard_arrow_down)),
                      menuItemStyleData: const MenuItemStyleData(
                        // height: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(12.r),
              sliver: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final param = GameListParam();
                  final response = ref.watch(gameListProvider(param: param));
                  if (response is LoadingModel) {
                    return SliverToBoxAdapter();
                  }
                  response as ResponseListModel<GameModel>;
                  final model = response.data!;
                  return SliverList.separated(
                    itemBuilder: (_, idx) {
                      return GameCard.fromModel(
                        model: model[idx],
                      );
                    },
                    separatorBuilder: (_, idx) {
                      return SizedBox(height: 10.h);
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
