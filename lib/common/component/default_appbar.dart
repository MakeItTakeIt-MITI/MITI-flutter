import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/theme/text_theme.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final PreferredSizeWidget? bottom;
  final bool isSliver;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const DefaultAppBar(
      {super.key,
      this.title,
      this.bottom,
      this.isSliver = false,
      this.actions,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    log('context.canPop() = ${context.canPop()}');
    if (isSliver) {
      return SliverAppBar(
        title: Text(
          title ?? '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25.sp,
          ),
        ),
        backgroundColor: backgroundColor ?? Colors.white,

        /// 앱바 pinned 시 surface 컬러
        surfaceTintColor: backgroundColor ?? Colors.white,
        shape: const Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
        centerTitle: true,
        leading: context.canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: SvgPicture.asset('assets/images/icon/chevron_left.svg'),
              )
            : null,
        bottom: bottom,
        actions: actions,
        pinned: true,
      );
    }
    return AppBar(
      title: Text(
        title ?? '',
        style: MITITextStyle.pageNameStyle.copyWith(
          color: Colors.black,
        ),
      ),
      surfaceTintColor: Colors.white,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: const Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
      centerTitle: true,
      leading: context.canPop()
          ? IconButton(
              onPressed: () => context.pop(),
              icon: SvgPicture.asset('assets/images/icon/chevron_left.svg'),
            )
          : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom != null ? bottom!.preferredSize.height : 0;
    return Size.fromHeight(48.h + bottomHeight);
  }
}
