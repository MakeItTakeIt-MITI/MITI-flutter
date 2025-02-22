import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/theme/color_theme.dart';

import '../../theme/text_theme.dart';
import '../model/court_model.dart';
import '../model/v2/court_map_response.dart';

class ResultCard extends StatelessWidget {
  final int courtId;
  final String name;
  final String address;
  final bool isShare;
  final VoidCallback onTap;

  const ResultCard(
      {super.key,
      required this.name,
      required this.address,
      required this.courtId,
      required this.onTap,
      required this.isShare});

  factory ResultCard.fromModel(
      {required CourtMapResponse model,
      required VoidCallback onTap,
      bool isShare = false}) {
    final address = '${model.address} ${model.addressDetail ?? ''}';
    return ResultCard(
      name: model.name ?? '미정',
      address: address,
      courtId: model.id,
      onTap: onTap,
      isShare: isShare,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
            color: MITIColor.gray700,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: MITIColor.gray600)),
        child: Row(
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
                  ),
                ],
              ),
            ),
            // if (!isShare)
            //   SvgPicture.asset(
            //     'assets/images/icon/chevron_right.svg',
            //     height: 14.h,
            //     width: 7.w,
            //   ),
            // if (isShare)
            //   SvgPicture.asset(
            //     'assets/images/icon/share.svg',
            //     height: 30.h,
            //     width: 30.w,
            //   ),
          ],
        ),
      ),
    );
  }
}
