import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';

class BankTransferListSkeleton extends StatelessWidget {
  const BankTransferListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const BankTransferCardSkeleton(),
        SizedBox(
          height: 8.h,
        ),
        const BankTransferCardSkeleton(),
        SizedBox(
          height: 8.h,
        ),
        const BankTransferCardSkeleton(),
      ],
    );
  }
}

class BankTransferCardSkeleton extends StatelessWidget {
  const BankTransferCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: MITIColor.gray750),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxSkeleton(width: 76, height: 18),
                BoxSkeleton(width: 50, height: 18),
              ],
            ),
            SizedBox(height: 12.h),
            const BoxSkeleton(width: 33, height: 14),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: MITIColor.gray700,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BoxSkeleton(width: 32, height: 12),
                      BoxSkeleton(width: 32, height: 12),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BoxSkeleton(width: 54, height: 12),
                      BoxSkeleton(width: 95, height: 12),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BoxSkeleton(width: 54, height: 12),
                      BoxSkeleton(width: 131, height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
