import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final PreferredSizeWidget? bottom;
  final bool isSliver;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final String leadingIcon;
  final bool hasBorder;
  final bool canPop;

  const DefaultAppBar({
    super.key,
    this.title,
    this.bottom,
    this.isSliver = false,
    this.actions,
    this.backgroundColor,
    this.leadingIcon = "back_arrow",
    this.hasBorder = true,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    // log('context.canPop() = ${context.canPop()}');
    if (isSliver) {
      return SliverAppBar(
        toolbarHeight: 44.h,
        leadingWidth: 24.r + 13.w,
        title: Text(
          title ?? '',
          style: MITITextStyle.mdBold.copyWith(
            color: MITIColor.white,
          ),
        ),
        backgroundColor: backgroundColor ?? MITIColor.gray800,
        floating: false,
        // AppBar가 떠 있지 않게 설정
        expandedHeight: null,
        // 확장되지 않도록 설정
        flexibleSpace: null,
        // 유연한 공간을 설정하지 않음
        /// 앱바 pinned 시 surface 컬러
        surfaceTintColor: backgroundColor ?? MITIColor.gray800,
        shape: hasBorder
            ? const Border(
                bottom: BorderSide(color: MITIColor.gray600),
              )
            : Border(
                bottom: BorderSide(color: backgroundColor ?? MITIColor.gray800),
              ),
        centerTitle: true,

        leading: context.canPop() && canPop
            ? Padding(
                padding: EdgeInsets.only(left: 13.w),
                child: IconButton(
                  constraints: BoxConstraints.tight(Size(24.r, 24.r)),
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: SvgPicture.asset(
                    AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: leadingIcon,
                    ),
                    height: 24.r,
                    width: 24.r,
                  ),
                ),
              )
            : null,
        bottom: bottom,
        actions: actions,
        pinned: true,
      );
    }
    return AppBar(
      toolbarHeight: 44.h,
      leadingWidth: 24.r + 13.w,
      shape: hasBorder
          ? const Border(
              bottom: BorderSide(color: MITIColor.gray600),
            )
          : Border(
              bottom: BorderSide(color: backgroundColor ?? MITIColor.gray800),
            ),
      title: Text(
        title ?? '',
        style: MITITextStyle.mdBold.copyWith(
          color: MITIColor.white,
        ),
      ),
      backgroundColor: backgroundColor ?? MITIColor.gray800,

      /// 앱바 pinned 시 surface 컬러
      surfaceTintColor: backgroundColor ?? MITIColor.gray800,
      centerTitle: true,
      leading: context.canPop() && canPop
          ? Padding(
              padding: EdgeInsets.only(left: 13.w),
              child: IconButton(
                constraints: BoxConstraints.tight(Size(24.r, 24.r)),
                padding: EdgeInsets.zero,
                onPressed: () => context.pop(),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                icon: SvgPicture.asset(
                  AssetUtil.getAssetPath(
                    type: AssetType.icon,
                    name: leadingIcon,
                  ),
                  height: 24.r,
                  width: 24.r,
                ),
              ),
            )
          : null,
      bottom: bottom,
      actions: actions,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom != null ? 44.h : 0;
    return Size.fromHeight(44.h + bottomHeight);
  }
}
