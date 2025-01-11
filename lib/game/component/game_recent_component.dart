import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/model/game_recent_host_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../court/component/court_list_component.dart';
import '../provider/widget/game_form_provider.dart';

class GameRecentComponent extends ConsumerWidget {
  final List<GameRecentHostModel> models;
  final List<TextEditingController> textEditingControllers;

  const GameRecentComponent(
      {super.key, required this.models, required this.textEditingControllers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21.w),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: MITIColor.gray700,
            borderRadius: BorderRadius.circular(20.r),
          ),
          // constraints: BoxConstraints(maxHeight: 504.h),
          // alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "최근 호스팅 목록",
                        style: MITITextStyle.mdBold.copyWith(
                          color: MITIColor.gray100,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgPicture.asset(
                          AssetUtil.getAssetPath(
                              type: AssetType.icon, name: 'remove'),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "최근 호스팅한 경기 목록입니다.\n같은 정보로 경기를 생성하시겠습니까?",
                    style: MITITextStyle.xxsmLight150.copyWith(
                      color: MITIColor.gray300,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (_, idx) {
                    return _GameRecentCard.fromModel(
                      model: models[idx],
                    );
                  },
                  separatorBuilder: (_, idx) => SizedBox(
                        height: 12.h,
                      ),
                  itemCount: models.length),
              SizedBox(height: 20.h),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final selected = ref.watch(selectedProvider);
                  return TextButton(
                      onPressed: selected != null
                          ? () {
                              selectRecentGame(selected, ref, context);
                            }
                          : () {},
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              selected != null
                                  ? MITIColor.primary
                                  : MITIColor.gray500)),
                      child: Text(
                        "경기 정보 불러오기",
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

  void selectRecentGame(int selected, WidgetRef ref, BuildContext context) {
    final model = models.firstWhere((m) => m.id == selected);
    ref.read(gameFormProvider.notifier).selectGameHistory(
        model: model, textEditingControllers: textEditingControllers);
    context.pop();
  }
}

class _GameRecentCard extends ConsumerWidget {
  final int id;
  final String title;
  final String address;

  const _GameRecentCard({
    super.key,
    required this.id,
    required this.title,
    required this.address,
  });

  factory _GameRecentCard.fromModel({
    required GameRecentHostModel model,
  }) {
    final address =
        '${model.court.address} ${(model.court.address_detail ?? '')}';
    return _GameRecentCard(
      title: model.title,
      address: address,
      id: model.id,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedProvider) == id;
    return GestureDetector(
      onTap: () {
        final selectedId = ref.read(selectedProvider);
        if (selectedId == id) {
          ref.read(selectedProvider.notifier).update((state) => null);
        } else {
          ref.read(selectedProvider.notifier).update((state) => id);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: selected ? MITIColor.primary : Colors.transparent),
          color: MITIColor.gray600,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: MITITextStyle.mdBold.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MITITextStyle.xxsm.copyWith(
                      color: MITIColor.gray400,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              AssetUtil.getAssetPath(
                  type: AssetType.icon, name: 'active_check'),
              colorFilter: ColorFilter.mode(
                  selected ? MITIColor.primary : MITIColor.gray800,
                  BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
