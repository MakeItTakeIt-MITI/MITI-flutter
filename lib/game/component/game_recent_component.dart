import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../court/component/court_list_component.dart';
import '../../notification/model/game_chat_notification_response.dart';
import '../model/v2/game/game_with_court_response.dart';

class GameBottomSheetCard extends ConsumerWidget {
  final int id;
  final String title;
  final String content;

  const GameBottomSheetCard({
    super.key,
    required this.id,
    required this.title,
    required this.content,
  });

  factory GameBottomSheetCard.fromRecentModel({
    required GameWithCourtResponse model,
  }) {
    final address =
        '${model.court.address} ${(model.court.addressDetail ?? '')}';
    return GameBottomSheetCard(
      title: model.title,
      content: address,
      id: model.id,
    );
  }

  factory GameBottomSheetCard.fromUserChatNoticeModel({
    required GameChatNotificationResponse model,
  }) {
    return GameBottomSheetCard(
      title: model.title,
      content: model.body,
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
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
              color: selected ? V2MITIColor.primary5 : V2MITIColor.gray6),
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
                    overflow: TextOverflow.ellipsis,
                    style: V2MITITextStyle.smallMedium.copyWith(
                      color: V2MITIColor.gray3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: V2MITITextStyle.tinyRegularTight.copyWith(
                      color: V2MITIColor.gray3,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              AssetUtil.getAssetPath(
                  type: AssetType.icon, name: 'check'),
              colorFilter: ColorFilter.mode(
                  selected ? V2MITIColor.primary5 : V2MITIColor.gray3,
                  BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
