import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/game/view/game_list_screen.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../common/component/default_appbar.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/provider/scroll_provider.dart';
import '../../game/component/game_list_component.dart';
import '../../game/model/game_model.dart';
import '../../game/param/game_param.dart';
import '../../game/provider/game_provider.dart';

class GameHostScreen extends ConsumerStatefulWidget {
  static String get routeName => 'host';
  final UserGameType type;

  const GameHostScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<GameHostScreen> createState() => _GameHostScreenState();
}

class _GameHostScreenState extends ConsumerState<GameHostScreen> {
  final List<String> items = [
    '모집중',
    '모집 완료',
    '경기 취소',
    '경기 완료',
    '전체 보기',
  ];
  String? selectedValue = '전체 보기';

  GameStatus? getStatus(String value) {
    switch (value) {
      case '모집중':
        return GameStatus.open;
      case '모집 완료':
        return GameStatus.closed;
      case '경기 취소':
        return GameStatus.canceled;
      case '경기 완료':
        return GameStatus.completed;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pageScrollControllerProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: controller[1],
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            DefaultAppBar(
              title:
                  widget.type == UserGameType.host ? '나의 호스팅 경기' : '나의 참여 경기',
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
                            final gameStatus = getStatus(value!);
                            ref
                                .read(userHostingProvider(type: widget.type)
                                    .notifier)
                                .getHosting(
                                    game_status: gameStatus,
                                    paginationParam: PaginationParam(page: 1),
                                    type: widget.type);
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
                  final response =
                      ref.watch(userHostingProvider(type: widget.type));
                  if (response is LoadingModel) {
                    return const SliverToBoxAdapter(
                      child: CircularProgressIndicator(),
                    );
                  }
                  response as PaginationModel<GameListByDateModel>;
                  final model = response.page_content;
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
