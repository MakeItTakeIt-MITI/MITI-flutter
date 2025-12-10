import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/html_component.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../component/default_appbar.dart';

class OperationTermScreen extends StatelessWidget {
  final String title;
  final String desc;
  final VoidCallback onPressed;

  const OperationTermScreen(
      {super.key,
      required this.title,
      required this.desc,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: const DefaultAppBar(
          hasBorder: false,
          leadingIcon: "remove",
        ),
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: V2MITITextStyle.title3.copyWith(
                  color: V2MITIColor.white,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HtmlComponent(content: desc),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 39.h),
              TextButton(onPressed: onPressed, child: const Text("확인")),
              SizedBox(height: 21.h),
            ],
          ),
        ),
      ),
    );
  }
}
