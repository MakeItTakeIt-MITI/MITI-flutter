import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';
import 'package:miti/theme/color_theme.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 21.w,
        vertical: 20.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxSkeleton(
                  height: 20.h,
                  width: 152.w,
                ),
                SizedBox(height: 16.h),
                BoxSkeleton(
                  height: 24.h,
                  width: 80.w,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  borderRadius: 200,
                ),
              ],
            ),
          ),
          CustomSkeleton(
            skeleton: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: MITIColor.gray600,
              ),
              width: 60.r,
              height: 60.r,
            ),
          )
        ],
      ),
    );
  }
}
