import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class FlashUtil {
  static void showFlash(
      BuildContext context, String content, {Color? textColor}) {
    context.showFlash(
        builder: (BuildContext context, FlashController controller) {
      Future.delayed(const Duration(seconds: 1), () {
        controller.dismiss();
      });
      return DefaultFlash(
        controller: controller,
        content: content,
      );
    });
  }
}

class DefaultFlash extends StatelessWidget {
  final FlashController controller;
  final String content;
  final Color textColor;

  const DefaultFlash(
      {super.key,
      required this.controller,
      required this.content,
      this.textColor = MITIColor.correct});

  @override
  Widget build(BuildContext context) {
    return FlashBar(
        position: FlashPosition.top,
        controller: controller,
        useSafeArea: false,
        // toolbarHeight 추가
        margin: EdgeInsets.only(top: 98.h, left: 78.w, right: 78.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        backgroundColor: MITIColor.gray700,
        padding: EdgeInsets.all(10.r),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: MITITextStyle.smBold.copyWith(
            color: textColor,
          ),
        ));
  }
}
