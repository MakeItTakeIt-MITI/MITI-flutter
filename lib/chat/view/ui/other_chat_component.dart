import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../model/chat_ui_model.dart';

class OtherChatBubble extends StatelessWidget {
  final String profileImageUrl;
  final String nickname;
  final String message;
  final String time;
  final bool isMine;
  final bool showTime;
  final bool showUserInfo;

  const OtherChatBubble({
    super.key,
    required this.profileImageUrl,
    required this.nickname,
    required this.message,
    required this.isMine,
    required this.time,
    required this.showTime,
    required this.showUserInfo,
  });

  factory OtherChatBubble.fromModel({required ChatModel chat}) {
    return OtherChatBubble(
      profileImageUrl: chat.user.profileImageUrl,
      nickname: chat.user.nickname,
      message: chat.message,
      isMine: chat.isMine,
      time: chat.time,
      showTime: chat.showTime,
      showUserInfo: chat.showUserInfo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showUserInfo)
          CircleAvatar(
            radius: 12.r,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(profileImageUrl, scale: 24.r),
          )
        else
          SizedBox(
            width: 24.r,
          ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: showUserInfo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      style: MITITextStyle.sm,
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ChatBox(
                    message: message,
                    isMine: isMine,
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Visibility(
                    visible: showTime,
                    child: Text(
                      time,
                      style:
                          MITITextStyle.sm.copyWith(color: MITIColor.gray500),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class ChatBox extends StatelessWidget {
  final String message;
  final bool isMine;

  const ChatBox({super.key, required this.isMine, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.all(8.r),
        constraints: BoxConstraints(maxWidth: 240.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: isMine ? MITIColor.primary : MITIColor.gray750),
        child: Text(
          message,
          style: MITITextStyle.sm.copyWith(
            color: isMine ? MITIColor.gray900 : MITIColor.gray100,
          ),
        ),
      ),
    );
  }
}
