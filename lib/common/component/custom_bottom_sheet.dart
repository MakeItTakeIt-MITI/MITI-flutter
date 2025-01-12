import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/color_theme.dart';

Future<void> showCustomModalBottomSheet(
    BuildContext context, Widget child) async {
 await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      backgroundColor: MITIColor.gray800,
      builder: (context) {
        return Padding(
            padding: EdgeInsets.only(
                left: 16.w, right: 16.w, top: 20.h, bottom: 45.h),
            child: child);
      });
}
