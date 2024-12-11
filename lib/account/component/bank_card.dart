import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../common/model/entity_enum.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class BankCard extends StatelessWidget {
  final BankType bank;
  final bool isSelected;

  const BankCard({super.key, required this.bank, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    List<BankType> pngBank = [
      BankType.SAEMAUL,
      BankType.TOSSBANK,
      BankType.KDBBANK
    ];

    return Container(
      width: 76.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color:isSelected ? MITIColor.primary : MITIColor.gray800) ,
        color: MITIColor.gray750,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (pngBank.contains(bank))
            Image.asset(
              AssetUtil.getAssetPath(
                  type: AssetType.logo,
                  name: 'bank/${bank.displayName}',
                  extension: "png"),
              height: 20.h,
            )
          else
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
