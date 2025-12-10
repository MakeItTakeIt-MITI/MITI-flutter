import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../util/util.dart';
import '../model/v2/court_map_response.dart';

class CourtAddressCard extends StatelessWidget {
  final int id;
  final String name;
  final String address;
  final bool selected;
  final VoidCallback onTap;

  const CourtAddressCard(
      {super.key,
      required this.address,
      required this.name,
      required this.id,
      required this.selected,
      required this.onTap});

  factory CourtAddressCard.fromModel({
    required CourtMapResponse model,
    required VoidCallback onTap,
    required bool selected,
  }) {
    return CourtAddressCard(
      address: '${model.address} ${model.addressDetail ?? ''}',
      name: model.name ?? '미정',
      id: model.id,
      selected: selected,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: MITIColor.gray600,
          border: Border.all(
              color: selected ? V2MITIColor.primary5 : Colors.transparent),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    style: MITITextStyle.mdBold.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address,
                    style: MITITextStyle.xxsm.copyWith(
                      color: MITIColor.gray400,
                    ),
                  )
                ],
              ),
            ),
            SvgPicture.asset(
              AssetUtil.getAssetPath(
                  type: AssetType.icon, name: "active_check"),
              height: 24.r,
              width: 24.r,
              colorFilter: ColorFilter.mode(
                  selected ? V2MITIColor.primary5 : MITIColor.gray800,
                  BlendMode.srcIn),
            )
          ],
        ),
      ),
    );
  }
}
