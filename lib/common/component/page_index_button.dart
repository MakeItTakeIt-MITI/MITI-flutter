import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class PageIndexButton extends StatelessWidget {
  final int startIdx;
  final int endIdx;
  final int currentIdx;

  const PageIndexButton(
      {super.key,
      required this.startIdx,
      required this.endIdx,
      required this.currentIdx});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.chevron_left,
              size: 24.r,
              color: const Color(0xFF999999),
            ),
          ),
          ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (_, idx) {
                return _IdxButton(
                  idx: idx,
                  selected: currentIdx - 1 == idx,
                  onTap: () {},
                );
              },
              separatorBuilder: (_, idx) => SizedBox(width: 4.w),
              itemCount: 11 >= 5 ? 5 : 11),
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.chevron_right,
              size: 24.r,
              color: const Color(0xFF999999),
            ),
          )
        ],
      ),
    );
  }
}

class _IdxButton extends StatelessWidget {
  final int idx;
  final bool selected;
  final VoidCallback onTap;

  const _IdxButton(
      {super.key,
      required this.idx,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24.r,
        width: 24.r,
        alignment: Alignment.center,
        child: Text(
          "${idx + 1}",
          style: MITITextStyle.xxsmBold.copyWith(
              color: selected ? MITIColor.primary : MITIColor.gray500),
        ),
      ),
    );
  }
}
