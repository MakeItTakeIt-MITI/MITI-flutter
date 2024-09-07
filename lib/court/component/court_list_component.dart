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

import '../../common/component/page_index_button.dart';
import '../../common/model/default_model.dart';
import '../model/court_model.dart';
import '../provider/court_provider.dart';

final selectedProvider = StateProvider.autoDispose<int?>((ref) => null);

class CourtListComponent extends StatelessWidget {
  final ResponseModel<PaginationModel<CourtSearchModel>> model;

  const CourtListComponent({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
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
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
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
                              selected:
                                  selected == model.data!.page_content[idx].id,
                              onTap: () {
                                onTap(ref, idx);
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
              PageIndexButton(
                startIdx: model.data!.start_index,
                endIdx: model.data!.end_index,
                currentIdx: model.data!.current_index,
              ),
              SizedBox(
                height: 24.r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chevron_left,
                      size: 24.r,
                      color: const Color(0xFF999999),
                    ),
                    SizedBox(width: 20.w),
                    ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (_, idx) {
                          final currentIdx = model.data!.current_index;
                          bool selected = currentIdx - 1 == idx;
                          return Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(selectedProvider.notifier)
                                      .update((state) => idx);
                                },
                                child: Container(
                                  height: 24.r,
                                  width: 24.r,
                                  decoration: selected
                                      ? const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MITIColor.primary,
                                        )
                                      : null,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${idx + 1}",
                                    style: MITITextStyle.xxsm.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: selected
                                            ? MITIColor.gray800
                                            : MITIColor.gray500),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, idx) => SizedBox(width: 4.w),
                        itemCount: 11 >= 5 ? 5 : 11),
                    SizedBox(width: 20.w),
                    Icon(
                      Icons.chevron_right,
                      size: 24.r,
                      color: const Color(0xFF999999),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final selected = ref.watch(selectedProvider);
                  return TextButton(
                      onPressed: selected != null
                          ? () {
                              selectCourt(ref, context);
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

  void onTap(WidgetRef ref, int idx) {
    final selectId = ref.read(selectedProvider);
    if (selectId == model.data!.page_content[idx].id) {
      ref.read(selectedProvider.notifier).update((state) => null);
    } else {
      ref
          .read(selectedProvider.notifier)
          .update((state) => model.data!.page_content[idx].id);
    }
  }

  void selectCourt(WidgetRef ref, BuildContext context) {
    final selectId = ref.read(selectedProvider);

    final selectModel =
        model.data!.page_content.firstWhere((m) => m.id == selectId);

    final court = ref.read(gameFormProvider).court;
    final newCourt = court.copyWith(
        name: selectModel.name, address_detail: selectModel.address_detail);

    ref.read(gameFormProvider.notifier).update(court: newCourt);
    context.pop();
  }
}
