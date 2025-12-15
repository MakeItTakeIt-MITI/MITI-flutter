import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SystemButtonBottom extends StatelessWidget {
  final List<Widget> buttons;

  const SystemButtonBottom({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      child: Column(
        spacing: 16.h,
        mainAxisSize: MainAxisSize.min,
        children: buttons,
      ),
    );
  }
}
