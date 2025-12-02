import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class FilterChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChip({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        backgroundColor: isSelected ? V2MITIColor.primary5 : V2MITIColor.gray12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
          side: BorderSide(
            color: isSelected ? V2MITIColor.primary5 : V2MITIColor.gray8,
          ),
        ),
        label: Text(
          text,
          style: V2MITITextStyle.tinyMedium.copyWith(
            color: isSelected ? V2MITIColor.black : V2MITIColor.gray5,
          ),
        ),
      ),
    );
  }
}
