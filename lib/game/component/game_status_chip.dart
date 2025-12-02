import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class GameStatusChip extends StatelessWidget {
  final String text;

  final VoidCallback onDeleted;

  const GameStatusChip(
      {super.key, required this.text, required this.onDeleted});

  @override
  Widget build(BuildContext context) {


    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      child: Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

        // 여백 제거
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        labelPadding: EdgeInsets.only(right: 4.w),
        onDeleted: onDeleted,
        deleteIcon: SvgPicture.asset(
          AssetUtil.getAssetPath(
            type: AssetType.icon,
            name: 'close',
          ),
          colorFilter:
          const ColorFilter.mode(V2MITIColor.primary5, BlendMode.srcIn),
        ),
        label: Text(
          text,
          style: V2MITITextStyle.tinyMedium.copyWith(
            color: V2MITIColor.primary5,
          ),
        ),
        backgroundColor: V2MITIColor.gray12,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: V2MITIColor.gray11,
          ),
          borderRadius: BorderRadius.circular(50.r),
        ),
      ),
    );
  }
}
