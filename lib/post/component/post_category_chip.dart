import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../common/model/entity_enum.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class PostCategoryChip extends StatelessWidget {
  final GlobalKey? globalKey;
  final PostCategoryType category;
  final bool isSelected;
  final VoidCallback onTap;
  final Color backgroundColor;

  const PostCategoryChip({
    super.key,
    required this.category,
    required this.onTap,
    required this.isSelected,
    this.backgroundColor = MITIColor.gray900,  this.globalKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      key: globalKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        height: 32.h,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
                color: isSelected ? MITIColor.primaryLight : MITIColor.gray600,
                width: .5),
            color: isSelected ? MITIColor.primaryLight : backgroundColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.displayName,
                style: MITITextStyle.xxsm.copyWith(
                    color: isSelected ? MITIColor.gray900 : MITIColor.gray300)),
            if (category != PostCategoryType.all) SizedBox(width: 2.w),
            if (category != PostCategoryType.all)
              SvgPicture.asset(
                AssetUtil.getAssetPath(type: AssetType.icon, name: "search"),
                height: 12.r,
                width: 12.r,
              )
          ],
        ),
      ),
    );
  }
}
