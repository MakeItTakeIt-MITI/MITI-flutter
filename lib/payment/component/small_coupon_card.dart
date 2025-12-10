import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miti/theme/color_theme.dart';

import '../../common/model/entity_enum.dart';
import '../../theme/text_theme.dart';
import '../model/base_coupon_usage_response.dart';

class SmallCouponCard extends StatelessWidget {
  final int id;

  /// 쿠폰 이름
  final String name;

  /// 쿠폰 상태
  final CouponStatusType status;

  /// 쿠폰 사용 가능 품목
  final ItemType targetItemType;

  /// 할인 유형
  final DiscountType discountType;

  /// 할인 값
  final int discountValue;

  /// 최대 할인 금액
  final int? maxDiscountAmount;

  /// 최종 적용 할인 금액
  final int discountAmount;

  /// 쿠폰 발행일
  final DateTime issuedAt;

  /// 유효 시작일
  final DateTime? validFrom;

  /// 유효 마감일 (null 반환 가능)
  final DateTime? validUntil;

  const SmallCouponCard(
      {super.key,
      required this.id,
      required this.name,
      required this.status,
      required this.targetItemType,
      required this.discountType,
      required this.discountValue,
      this.maxDiscountAmount,
      required this.discountAmount,
      required this.issuedAt,
      this.validFrom,
      this.validUntil});

  factory SmallCouponCard.fromModel({required BaseCouponUsageResponse model}) {
    return SmallCouponCard(
      id: model.id,
      name: model.name,
      status: model.status,
      targetItemType: model.targetItemType,
      discountType: model.discountType,
      discountValue: model.discountValue,
      discountAmount: model.discountAmount,
      maxDiscountAmount: model.maxDiscountAmount,
      validFrom: model.validFrom,
      validUntil: model.validUntil,
      issuedAt: model.issuedAt,
    );
  }

  String getAmountFormatted(int value) =>
      NumberFormat.decimalPattern().format(value);

  @override
  Widget build(BuildContext context) {
    final discountTypeValue = discountType == DiscountType.fixed
        ? "${NumberFormat.decimalPattern().format(discountValue)}원"
        : "$discountValue%";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: V2MITIColor.gray1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.h,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name,
                style: V2MITITextStyle.regularBoldTight
                    .copyWith(color: V2MITIColor.white),
              ),
              Text(
                '$discountTypeValue 할인쿠폰',
                style: V2MITITextStyle.tinyMediumNormal
                    .copyWith(color: V2MITIColor.white),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4.h,
            children: [
              if (maxDiscountAmount != null)
                Text(
                  "${NumberFormat.decimalPattern().format(maxDiscountAmount)} 원",
                  style: V2MITITextStyle.miniMediumNormal
                      .copyWith(color: V2MITIColor.gray5),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (validUntil != null)
                    Text(
                      '유효기간: ${DateFormat('yyyy년 MM월 dd일').format(validUntil!)}',
                      style: V2MITITextStyle.miniMediumNormal
                          .copyWith(color: V2MITIColor.gray5),
                    ),
                  Row(
                    spacing: 4.w,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '할인 금액',
                        style: V2MITITextStyle.miniMediumNormal
                            .copyWith(color: V2MITIColor.white),
                      ),
                      Text(
                        "${NumberFormat.decimalPattern().format(discountAmount)} 원",
                        style: V2MITITextStyle.tinyMediumNormal
                            .copyWith(color: V2MITIColor.white),
                      ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
