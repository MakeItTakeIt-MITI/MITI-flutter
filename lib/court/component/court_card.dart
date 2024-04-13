import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:miti/court/model/court_model.dart';

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
    required CourtAddressModel model,
    required VoidCallback onTap,
    required selected,
  }) {
    return CourtAddressCard(
      address: '${model.address} ${model.address_detail}',
      name: model.name,
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
          border: Border.all(
              color:
                  selected ? const Color(0xFF4065F5) : const Color(0xFFE8E8E8)),
        ),
        padding: EdgeInsets.all(10.r),
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
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 11.sp,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.25.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    address,
                    style: TextStyle(
                      color: const Color(0xFF999999),
                      fontSize: 10.sp,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.25.sp,
                    ),
                  )
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/images/icon/select.svg',
              height: 24.r,
              width: 24.r,
              colorFilter: ColorFilter.mode(
                  selected ? const Color(0xFF4065F5) : const Color(0xFF666666),
                  BlendMode.srcIn),
            )
          ],
        ),
      ),
    );
  }
}
