import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final PreferredSizeWidget? bottom;
  final bool isSliver;

  const DefaultAppBar({super.key, this.title, this.bottom, this.isSliver = false});

  @override
  Widget build(BuildContext context) {
    if (isSliver){
      return SliverAppBar(
        title: Text(
          title ?? '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
        ),
        backgroundColor: Colors.white,
        shape: const Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: SvgPicture.asset('assets/images/icon/chevron_left.svg'),
        ),
        bottom: bottom,
      );
    }
    return AppBar(
      title: Text(
        title ?? '',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      backgroundColor: Colors.white,
      shape: const Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: SvgPicture.asset('assets/images/icon/chevron_left.svg'),
      ),
      bottom: bottom,
    );

  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom != null ? bottom!.preferredSize.height : 0;
    return Size.fromHeight(48.h + bottomHeight);
  }
}


