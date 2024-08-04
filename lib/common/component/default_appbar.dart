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

  const DefaultAppBar({
    super.key,
    this.title,
    this.bottom,
    this.isSliver = false,
    this.actions,
    this.backgroundColor,
    this.leadingIcon = "back_arrow",
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    log('context.canPop() = ${context.canPop()}');
    if (isSliver) {
      return SliverAppBar(
        title: Text(
          title ?? '',
          style: MITITextStyle.mdBold.copyWith(
            color: MITIColor.white,
          ),
        ),
        backgroundColor: backgroundColor ?? MITIColor.gray800,

        /// 앱바 pinned 시 surface 컬러
        surfaceTintColor: backgroundColor ?? MITIColor.gray800,
        shape: hasBorder
            ? const Border(
                bottom: BorderSide(color: MITIColor.gray600),
              )
            : null,
        centerTitle: true,
        leading: context.canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: SvgPicture.asset(
                  AssetUtil.getAssetPath(
                      type: AssetType.icon, name: leadingIcon),
                ),
              )
            : null,
        bottom: bottom,
        actions: actions,
        pinned: true,
      );
    }
    return AppBar(
      shape: hasBorder
          ? const Border(
        bottom: BorderSide(color: MITIColor.gray600),
      )
          : null,
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
      leading: context.canPop()
          ? IconButton(
              onPressed: () => context.pop(),
              icon: SvgPicture.asset(
                AssetUtil.getAssetPath(type: AssetType.icon, name: leadingIcon),
              ),
            )
          : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom != null ? 44.h : 0;
    return Size.fromHeight(44.h + bottomHeight);
  }
}
