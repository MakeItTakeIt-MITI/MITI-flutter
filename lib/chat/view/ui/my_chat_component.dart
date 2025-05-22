import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/chat/model/chat_ui_model.dart';
import 'package:miti/chat/view/ui/other_chat_component.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

class MyChatComponent extends StatelessWidget {
  final UserChatModel chat;

  const MyChatComponent({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "오후 13:13",
              style: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
            ),
            SizedBox(width: 5.w),
            const ChatBox(isMine: true),
          ],
        )
      ],
    );
  }
}
