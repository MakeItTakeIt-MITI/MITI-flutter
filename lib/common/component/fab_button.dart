
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class FABButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const FABButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        EdgeInsets.only(left: 12.w, right: 16.w, top: 10.h, bottom: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.r),
          color: V2MITIColor.primary5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              color: V2MITIColor.gray12,
            ),
            Text(
              text,
              style: V2MITITextStyle.regularBoldTight.copyWith(
                color: V2MITIColor.gray12,
              ),
            )
          ],
        ),
      ),
    );
  }
}
