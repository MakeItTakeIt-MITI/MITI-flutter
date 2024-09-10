import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../common/model/entity_enum.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class BankCard extends StatelessWidget {
  final BankType bank;

  const BankCard({super.key, required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: MITIColor.gray750,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            AssetUtil.getAssetPath(
                type: AssetType.logo, name: 'bank/${bank.displayName}'),
            height: 20.h,
          ),
          SizedBox(height: 4.h),
          Text(
            bank.displayName,
            style: MITITextStyle.xxxsm.copyWith(
              color: MITIColor.gray100,
            ),
          )
        ],
      ),
    );
  }
}
