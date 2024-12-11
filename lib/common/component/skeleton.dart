import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:shimmer/shimmer.dart';

class CustomSkeleton extends StatelessWidget {
  final Widget skeleton;

  const CustomSkeleton({super.key, required this.skeleton});

  @override
  Widget build(BuildContext context) {
    int timer = 1000;
    return Shimmer.fromColors(
      baseColor: MITIColor.gray600,
      highlightColor: MITIColor.gray700,
      period: Duration(milliseconds: timer),
      child: skeleton,
    );
  }
}

class BoxSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const BoxSkeleton({
    super.key,
    this.borderRadius = 4,
    required this.width,
    required this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSkeleton(
      skeleton: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius.r),
            color: MITIColor.gray600),
      ),
    );
  }
}
