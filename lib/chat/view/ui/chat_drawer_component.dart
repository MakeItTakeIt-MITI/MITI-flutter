import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/chat/view/ui/game_notice_component.dart';

import '../../../util/util.dart';
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameNoticeComponent(
              gameId: gameId,
            ),
            SizedBox(height: 10.h),
            ChatMemberComponent(
              gameId: gameId,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: SvgPicture.asset(
                  AssetUtil.getAssetPath(type: AssetType.icon, name: 'exit'),
                  width: 22.w,
                  height: 24.h,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
