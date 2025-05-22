import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

class OtherChatComponent extends StatelessWidget {
  const OtherChatComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12.r,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(
              'https://image-dev.makeittakeit.kr/user-profile-images/user_2.png',
              scale: 24.r),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "nickname",
                    style: MITITextStyle.sm,
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    "오후 12:00",
                    style: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
                  )
                ],
              ),
              SizedBox(height: 4.h),
              ChatBox(
                isMine: false,
              ),
              SizedBox(height: 8.h),
              ChatBox(
                isMine: false,
              )
            ],
          ),
        )
      ],
    );
  }
}

class ChatBox extends StatelessWidget {
  final bool isMine;

  const ChatBox({super.key, required this.isMine});

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
          "GAME CHAT MESSAGE LENGTH RANGE 1~1500 MAX LINE HEIGHT 130% LETTER SPACING -2%",
          style: MITITextStyle.sm.copyWith(
            color: isMine ? MITIColor.gray900 : MITIColor.gray100,
          ),
        ),
      ),
    );
  }
}
