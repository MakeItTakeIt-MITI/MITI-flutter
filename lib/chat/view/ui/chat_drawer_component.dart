import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/chat/view/ui/game_notice_component.dart';

import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import 'chat_member_component.dart';

class ChatDrawerComponent extends StatelessWidget {
  final int gameId;

  const ChatDrawerComponent({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            GameNoticeComponent(
              gameId: gameId,
            ),
            SizedBox(height: 10.h),
            ChatMemberComponent(
              gameId: gameId,
            )
          ],
        ),
      ),
    );
  }
}
