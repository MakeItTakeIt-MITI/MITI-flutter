import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/court/component/court_card.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

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
                                ref.read(selectedProvider.notifier).update(
                                    (state) =>
                                        model.data!.page_content[idx].id);

                                final court = ref.read(gameFormProvider).court;
                                final newCourt = court.copyWith(
                                    name: model.data!.page_content[idx].name,
                                    address_detail: model.data!
                                        .page_content[idx].address_detail);

                                ref
                                    .read(gameFormProvider.notifier)
                                    .update(court: newCourt);
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
              TextButton(
                  onPressed: () => context.pop(), child: const Text("경기장 정보 불러오기")),
            ],
          ),
        ),
      ),
    );
  }
}
