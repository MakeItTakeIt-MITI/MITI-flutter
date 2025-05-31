import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/chat/provider/chat_notice_provider.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/util/util.dart';

import '../../common/model/default_model.dart';
import '../../notification/model/game_chat_notification_response.dart';
import '../../theme/text_theme.dart';
import 'chat_notification_form_screen.dart';

class ChatNotificationScreen extends StatelessWidget {
  final int gameId;
  final int notificationId;

  static String get routeName => 'chatNotification';

  const ChatNotificationScreen(
      {super.key, required this.gameId, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray900,
      appBar: DefaultAppBar(
        title: "공지사항",
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final result = ref.watch(chatNoticeDetailProvider(
                  gameId: gameId, notificationId: notificationId));
              if (result is LoadingModel) {
                return Container();
              } else if (result is ErrorModel) {
                return Container();
              }
              final model =
                  (result as ResponseModel<GameChatNotificationResponse>).data!;
              final userId = ref.watch(authProvider)?.id;
              final isHost = model.host.id == userId;
              return Visibility(visible: isHost, child: child!);
            },
            child: Container(
              margin: EdgeInsets.only(right: 13.w),
              child: InkWell(
                borderRadius: BorderRadius.circular(100.r),
                onTap: () {
                  Map<String, String> pathParameters = {
                    'gameId': gameId.toString(),
                  };
                  Map<String, String> queryParameters = {
                    'notificationId': notificationId.toString(),
                  };
                  context.pushNamed(ChatNotificationFormScreen.createRouteName,
                      pathParameters: pathParameters,
                      queryParameters: queryParameters);
                },
                child: Container(
                  // Adding padding around the text to increase the tappable area
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Text(
                    "수정",
                    style: MITITextStyle.xxsmLight
                        .copyWith(color: MITIColor.primary),
                  ),
                ),
              ),
            ),
          )
        ],
        backgroundColor: MITIColor.gray900,
        hasBorder: false,
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final result = ref.watch(chatNoticeDetailProvider(
              gameId: gameId, notificationId: notificationId));
          if (result is LoadingModel) {
            return Container();
          } else if (result is ErrorModel) {
            return Container();
          }
          final model =
              (result as ResponseModel<GameChatNotificationResponse>).data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HostComponent.fromResponse(model: model),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        model.title,
                        style: MITITextStyle.sm150.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Divider(
                        height: 39.h,
                        thickness: 1.h,
                        color: MITIColor.gray750,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            model.body,
                            style: MITITextStyle.sm150.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _HostComponent extends StatelessWidget {
  final int? id;
  final String nickname; // 닉네임
  final String profileImageUrl; // 프로필 이미지 URL
  final DateTime createdAt;
  final DateTime? modifiedAt;

  const _HostComponent({
    super.key,
    required this.id,
    required this.nickname,
    required this.profileImageUrl,
    required this.createdAt,
    this.modifiedAt,
  });

  factory _HostComponent.fromResponse(
      {required GameChatNotificationResponse model}) {
    return _HostComponent(
      id: model.host.id,
      nickname: model.host.nickname,
      profileImageUrl: model.host.profileImageUrl,
      createdAt: model.createdAt,
      modifiedAt: model.modifiedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTimeUtil.formatDateTime(modifiedAt ?? createdAt);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.5.h),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 16.r,
            backgroundImage: NetworkImage(profileImageUrl, scale: 32.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  nickname,
                  style: MITITextStyle.xxsmSemiBold.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  dateTime,
                  style: MITITextStyle.xxxsm.copyWith(color: MITIColor.gray500),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
