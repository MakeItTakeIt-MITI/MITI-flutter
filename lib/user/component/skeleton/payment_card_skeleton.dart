import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';

class PaymentCardListSkeleton extends StatelessWidget {
  const PaymentCardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => const PaymentCardSkeleton(),
      itemCount: 5,
    );
  }
}

class PaymentCardSkeleton extends StatelessWidget {
  const PaymentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MITIColor.gray700,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxSkeleton(width: 22, height: 12),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BoxSkeleton(width: 45, height: 12),
                SizedBox(height: 8.h),
                const BoxSkeleton(width: 180, height: 16),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    const BoxSkeleton(width: 52, height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        '|',
                        style: MITITextStyle.xxsmLight.copyWith(
                          color: MITIColor.gray400,
                        ),
                      ),
                    ),
                    const BoxSkeleton(width: 45, height: 12),
                  ],
                )
              ],
            ),
          ),
          SizedBox(width: 50.w),
          const BoxSkeleton(width: 61, height: 18),
        ],
      ),
    );
  }
}
