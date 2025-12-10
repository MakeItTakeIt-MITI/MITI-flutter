import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class CommentUtilButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final String title;
  final bool isSelected;
  final int cnt;

  const CommentUtilButton({
    super.key,
    required this.icon,
    this.onTap,
    required this.title,
    required this.cnt,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // 핵심!
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            AssetUtil.getAssetPath(type: AssetType.icon, name: icon),
            width: 12.r,
            height: 12.r,
            colorFilter: ColorFilter.mode(
                isSelected ? V2MITIColor.primary5 : MITIColor.gray100,
                BlendMode.srcIn),
          ),
          SizedBox(width: 3.w),
          Text(
            title,
            style: MITITextStyle.xxsm.copyWith(
                color: isSelected ? V2MITIColor.primary5 : MITIColor.gray500),
          ),
          SizedBox(width: 1.w),
          Text(
            cnt.toString(),
            style: MITITextStyle.xxsm.copyWith(
                color: isSelected ? V2MITIColor.primary5 : MITIColor.gray500),
          ),
        ],
      ),
    );
  }
}
