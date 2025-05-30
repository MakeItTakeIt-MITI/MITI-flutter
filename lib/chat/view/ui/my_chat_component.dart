import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/chat/model/chat_ui_model.dart';
import 'package:miti/chat/view/ui/other_chat_component.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../model/base_game_chat_message_response.dart';

class MyChatBubble extends StatelessWidget {
  final String time;
  final String message;
  final bool isTimeLastUserMessage;

  const MyChatBubble({
    super.key,
    required this.time,
    required this.message,
    required this.isTimeLastUserMessage,
  });

  factory MyChatBubble.fromModel({required ChatModel chat}) {
    return MyChatBubble(
      time: chat.time,
      message: chat.message,
      isTimeLastUserMessage: chat.showTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: isTimeLastUserMessage,
              child: Text(
                time,
                style: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
              ),
            ),
            SizedBox(width: 5.w),
            ChatBox(
              isMine: true,
              message: message,
            ),
          ],
        )
      ],
    );
  }
}
