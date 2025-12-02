import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/game/component/filter_chip.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class FilterChipGroup<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Set<T> selectedItems; // Set으로 성능 최적화
  final Function(T) onItemTap;
  final String Function(T) itemToString;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const FilterChipGroup({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onItemTap,
    required this.itemToString,
    this.spacing = 6.0,
    this.runSpacing = 6.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 타이틀
          Text(
            title,
            style: V2MITITextStyle.smallBoldTight.copyWith(
              color: V2MITIColor.white,
            ),
          ),
          SizedBox(height: 12.h),

          // 칩들
          Wrap(
            spacing: spacing.r,
            runSpacing: runSpacing.r,
            children: items
                .map((item) => FilterChip(
                      isSelected: selectedItems.contains(item),
                      onTap: () => onItemTap(item),
                      text: itemToString(item),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
