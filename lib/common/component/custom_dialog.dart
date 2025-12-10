import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String btnDesc;
  final VoidCallback? onPressed;
  final Widget? button;

  const CustomDialog(
      {super.key,
      required this.title,
      this.onPressed,
      required this.content,
      this.btnDesc = '확인',
      this.button});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 333.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: MITIColor.gray800,
          ),
          padding:
              EdgeInsets.only(left: 20.w, right: 20.w, top: 28.h, bottom: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                content,
                textAlign: TextAlign.center,
                style: MITITextStyle.xxsmLight150.copyWith(
                  color: MITIColor.gray300,
                ),
              ),
              SizedBox(height: 30.h),
              if (button == null)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 48.h, minHeight: 48.h),
                  child: TextButton(
                    onPressed: onPressed ??
                        () => Navigator.of(context, rootNavigator: true)
                            .pop('dialog'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r))),
                    child: Text(
                      btnDesc,
                      style: MITITextStyle.mdBold.copyWith(
                        color: MITIColor.gray800,
                      ),
                    ),
                  ),
                )
              else
                button!
            ],
          ),
        ),
      ),
    );
  }
}

class V2BottomDialog extends StatelessWidget {
  final String content;
  final Widget btn;
  final bool hasPop;

  const V2BottomDialog(
      {super.key,
      required this.content,
      required this.btn,
      this.hasPop = false});

  Widget popButton(BuildContext context) {

    return Align(
        alignment: Alignment.topRight,
        child: IconButton(
            onPressed: () => context.pop(),
            style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStateProperty.all(EdgeInsets.zero)),
            constraints: BoxConstraints.tight(Size(24.r, 24.r)),
            icon: const Icon(
              Icons.close,
              color: V2MITIColor.white,
            )));
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        color: MITIColor.gray700,
      ),
      padding: EdgeInsets.only(
          left: 16.w, right: 16.w, top: hasPop ? 20.h : 30.h, bottom: 41.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPop) popButton(context),
          Text(
            content,
            textAlign: TextAlign.center,
            style: V2MITITextStyle.smallRegularNormal.copyWith(
              color: V2MITIColor.gray1,
            ),
          ),
          btn,
          if (Platform.isIOS)
            SizedBox(
              height: 21.h,
            )
        ],
      ),
    );
  }
}

class BottomDialog extends StatelessWidget {
  final String title;
  final String content;
  final Widget btn;
  final bool hasPop;

  const BottomDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.btn,
      this.hasPop = false});

  Widget popButton(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: IconButton(
            onPressed: () => context.pop(),
            style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStateProperty.all(EdgeInsets.zero)),
            constraints: BoxConstraints.tight(Size(24.r, 24.r)),
            icon: const Icon(
              Icons.close,
              color: V2MITIColor.white,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 196.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        color: MITIColor.gray700,
      ),
      padding: EdgeInsets.only(
          left: 20.w, right: 20.w, top: hasPop ? 20.h : 30.h, bottom: 41.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPop) popButton(context),
          Text(
            title,
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            content,
            textAlign: TextAlign.center,
            style: MITITextStyle.xxsmLight150.copyWith(
              color: MITIColor.gray300,
            ),
          ),
          SizedBox(height: 30.h),
          btn,
          if (Platform.isIOS)
            SizedBox(
              height: 21.h,
            )
        ],
      ),
    );
  }
}

class PermissionDialog extends StatelessWidget {
  final String title;

  const PermissionDialog({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 333.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: MITIColor.gray800,
        ),
        padding:
            EdgeInsets.only(left: 20.w, right: 20.w, top: 28.h, bottom: 20.h),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: MITITextStyle.mdBold150.copyWith(
                  color: MITIColor.gray100,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                          backgroundColor: MITIColor.gray700),
                      child: Text(
                        '확인',
                        style: MITITextStyle.mdSemiBold.copyWith(
                          color: V2MITIColor.primary5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await openAppSettings();
                        context.pop();
                      },
                      child: Text(
                        '설정',
                        style: MITITextStyle.mdSemiBold.copyWith(
                          color: MITIColor.gray800,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
