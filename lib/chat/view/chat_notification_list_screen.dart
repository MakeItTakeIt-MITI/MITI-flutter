import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/chat/provider/chat_notice_provider.dart';
import 'package:miti/chat/view/ui/game_notice_component.dart';
import 'package:miti/common/model/default_model.dart';

import '../../common/component/default_appbar.dart';
import '../../notification/model/base_game_chat_notification_response.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import 'chat_notification_form_screen.dart';
import 'chat_notification_screen.dart';

class ChatNotificationListScreen extends StatelessWidget {
  final int gameId;
  final bool isHost;

  static String get routeName => 'chatNotificationList';

  const ChatNotificationListScreen(
      {super.key, required this.gameId, required this.isHost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray900,
      appBar: DefaultAppBar(
        title: "공지사항",
        actions: [
          Visibility(
            visible: isHost,
            child: Container(
              margin: EdgeInsets.only(right: 13.w),
              child: InkWell(
                borderRadius: BorderRadius.circular(100.r),
                onTap: () {
                  Map<String, String> pathParameters = {
                    'gameId': gameId.toString()
                  };
                  context.pushNamed(ChatNotificationFormScreen.createRouteName,
                      pathParameters: pathParameters);
                },
                child: Container(
                  // Adding padding around the text to increase the tappable area
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Text(
                    "작성",
                    style: MITITextStyle.xxsmLight
                        .copyWith(color: V2MITIColor.primary5),
                  ),
                ),
              ),
            ),
          )
        ],
        backgroundColor: MITIColor.gray900,
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final result = ref.watch(chatNoticeProvider(gameId: gameId));
          if (result is LoadingModel) {
            return CircularProgressIndicator();
          } else if (result is ErrorModel) {
            return Text("Error");
          }

          final models =
              (result as ResponseListModel<BaseGameChatNotificationResponse>)
                  .data!;

          return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (_, idx) => NoticeItem.fromModel(
              model: models[idx],
              expand: true,
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
            itemCount: models.length,
          );
        },
      ),
    );
  }
}
