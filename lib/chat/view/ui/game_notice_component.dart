import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/auth/view/find_info/find_email_screen.dart';
import 'package:miti/chat/provider/chat_notice_provider.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../notification/model/base_game_chat_notification_response.dart';
import '../../../util/util.dart';
import '../chat_notification_form_screen.dart';
import '../chat_notification_screen.dart';

class GameNoticeComponent extends ConsumerWidget {
  final int gameId;

  const GameNoticeComponent({
    super.key,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "공지사항",
                style: MITITextStyle.lgBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              InkWell(
                onTap: () {
                  Map<String, String> pathParameters = {
                    'gameId': gameId.toString()
                  };
                  context.pushNamed(ChatNotificationFormScreen.routeName,
                      pathParameters: pathParameters);
                },
                child: SvgPicture.asset(
                  AssetUtil.getAssetPath(type: AssetType.icon, name: 'plus'),
                  width: 18.r,
                  height: 18.r,
                ),
              ),
            ],
          ),
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final result = ref.watch(chatNoticeProvider(gameId: gameId));
            if (result is LoadingModel) {
              return const CircularProgressIndicator();
            } else if (result is ErrorModel) {
              return Text("Error");
            }
            final models =
                (result as ResponseListModel<BaseGameChatNotificationResponse>)
                    .data!;

            if (models.isEmpty) {
              return Container(
                alignment: Alignment.center,
                height: 150.h,
                child: Text(
                  "아직 작성된 공지사항이 없습니다.",
                  style: MITITextStyle.smBold.copyWith(color: MITIColor.white),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              itemBuilder: (_, idx) => _NoticeItem.fromModel(
                model: models[idx],
                onTap: () {
                  Map<String, String> pathParameters = {
                    'gameId': gameId.toString(),
                    'notificationId': models[idx].id.toString()
                  };

                  context.pushNamed(ChatNotificationScreen.routeName,
                      pathParameters: pathParameters);
                },
              ),
              separatorBuilder: (_, idx) => const SizedBox(height: 0),
              itemCount: min(models.length, 4),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: GestureDetector(
            onTap: () {},
            child: Text(
              "공지사항 전체 보기",
              style: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
            ),
          ),
        )
      ],
    );
  }
}

class _NoticeItem extends StatelessWidget {
  final int id;
  final String title;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final VoidCallback onTap;

  const _NoticeItem({
    super.key,
    required this.id,
    required this.title,
    required this.createdAt,
    this.modifiedAt,
    required this.onTap,
  });

  factory _NoticeItem.fromModel({
    required BaseGameChatNotificationResponse model,
    required VoidCallback onTap,
  }) {
    return _NoticeItem(
      id: model.id,
      title: model.title,
      createdAt: model.createdAt,
      modifiedAt: model.modifiedAt,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTimeUtil.formatDateTime(modifiedAt ?? createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Row(
          children: [
            SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.icon, name: 'pin'),
              width: 12.r,
              height: 12.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: MITITextStyle.md.copyWith(
                      color: MITIColor.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dateTime,
                    style: MITITextStyle.xxsm.copyWith(
                      color: MITIColor.gray500,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
