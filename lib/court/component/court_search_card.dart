import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/text_theme.dart';
import '../model/court_model.dart';

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
      {required CourtSearchModel model,
      required VoidCallback onTap,
      bool isShare = false}) {
    final address = '${model.address} ${model.address_detail ?? ''}';
    return ResultCard(
      name: model.name,
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
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE8E8E8))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    style: MITITextStyle.courtNameCardStyle.copyWith(
                      color: const Color(0xff333333),
                    ),
                  ),
                  SizedBox(height: 9.h),
                  Text(
                    address,
                    style: MITITextStyle.courtAddressCardStyle.copyWith(
                      color: const Color(0xff999999),
                    ),
                  ),
                ],
              ),
            ),
            if (!isShare)
              SvgPicture.asset(
                'assets/images/icon/chevron_right.svg',
                height: 14.h,
                width: 7.w,
              ),
            if (isShare)
              SvgPicture.asset(
                'assets/images/icon/share.svg',
                height: 30.h,
                width: 30.w,
              ),
          ],
        ),
      ),
    );
  }
}
