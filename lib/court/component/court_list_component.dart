import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/court/component/court_card.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/bottom_page_count.dart';
import '../../common/component/page_index_button.dart';
import '../../common/model/default_model.dart';
import '../model/court_model.dart';
import '../provider/court_provider.dart';

final selectedProvider = StateProvider.autoDispose<int?>((ref) => null);

class CourtListComponent extends ConsumerWidget {
  const CourtListComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log("build!!");
    final result = ref.watch(courtListProvider);
    if (result is LoadingModel) {
      return Container();
    } else if (result is ErrorModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
      });
      return Container();
    }
    final model = result as ResponseModel<PaginationModel<CourtSearchModel>>;
    if (model.data!.page_content.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
      });
      return Container();
    } else {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Container(
            // width: 255.w,
            decoration: BoxDecoration(
              color: MITIColor.gray700,
              borderRadius: BorderRadius.circular(20.r),
            ),
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '경기장 목록',
                      style: MITITextStyle.mdBold.copyWith(
                        color: MITIColor.gray100,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, idx) {
                          return Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              final selected = ref.watch(selectedProvider);
                              return CourtAddressCard.fromModel(
                                model: model.data!.page_content[idx],
                                selected: selected ==
                                    model.data!.page_content[idx].id,
                                onTap: () {
                                  onTap(ref, idx, model);
                                },
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, idx) {
                          return SizedBox(height: 6.h);
                        },
                        itemCount: model.data!.page_content.length);
                  },
                ),
                SizedBox(height: 20.h),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return BottomPageCount(
                      pModelList: model.data!,
                      onTapPage: (int page) async {
                        ref
                            .read(courtListProvider.notifier)
                            .getList(page: page);
                      },
                      onPageStart: () async {
                        ref
                            .read(courtListProvider.notifier)
                            .getList(page: model.data!.start_index);
                      },
                      onPageLast: () async {
                        ref
                            .read(courtListProvider.notifier)
                            .getList(page: model.data!.end_index);
                      },
                      isSliver: false,
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final selected = ref.watch(selectedProvider);
                    return TextButton(
                        onPressed: selected != null
                            ? () {
                                selectCourt(ref, context, model);
                              }
                            : () {},
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                selected != null
                                    ? MITIColor.primary
                                    : MITIColor.gray500)),
                        child: Text(
                          "경기장 정보 불러오기",
                          style: MITITextStyle.mdBold.copyWith(
                              color: selected != null
                                  ? MITIColor.gray800
                                  : MITIColor.gray50),
                        ));
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void onTap(WidgetRef ref, int idx,
      ResponseModel<PaginationModel<CourtSearchModel>> model) {
    final selectId = ref.read(selectedProvider);
    if (selectId == model.data!.page_content[idx].id) {
      ref.read(selectedProvider.notifier).update((state) => null);
    } else {
      ref
          .read(selectedProvider.notifier)
          .update((state) => model.data!.page_content[idx].id);
    }
  }

  void selectCourt(WidgetRef ref, BuildContext context,
      ResponseModel<PaginationModel<CourtSearchModel>> model) {
    context.pop();
    /// 게임 생성 폼을 닫은 후 늦게 갱신 !!
    /// 게임 폼이 부모 트리에 있기 때문에 갱신 되면 build를 하면서
    /// 자식인 해당 다이어로그까지 build 되어 닫히는게 버벅이는 현상이 있기 때문
    Future.delayed(const Duration(milliseconds: 100), () {
      final selectId = ref.read(selectedProvider);

      final selectModel =
          model.data!.page_content.firstWhere((m) => m.id == selectId);

      final court = ref.read(gameFormProvider).court;
      final newCourt = court.copyWith(
          name: selectModel.name, address_detail: selectModel.address_detail);

      ref.read(gameFormProvider.notifier).update(court: newCourt);
    });
  }
}
