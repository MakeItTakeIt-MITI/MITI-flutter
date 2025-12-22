import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../common/model/entity_enum.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../model/base_coupon_policy_response.dart';
import '../model/coupon_response.dart';

class CouponCard extends StatelessWidget {
  final int id;
  final CouponStatusType status;

  final DateTime issuedAt;

  final DateTime validFrom;

  final DateTime validUntil;

  final BaseCouponPolicyResponse policy;

  final bool isExpired;

  const CouponCard(
      {super.key,
      required this.id,
      required this.status,
      required this.issuedAt,
      required this.validFrom,
      required this.validUntil,
      required this.policy,
      required this.isExpired});

  factory CouponCard.fromModel(
      {required CouponResponse model, required bool isExpired}) {
    return CouponCard(
      id: model.id,
      status: model.status,
      issuedAt: model.issuedAt,
      validFrom: model.validFrom,
      validUntil: model.validUntil,
      policy: model.policy,
      isExpired: isExpired,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPercent = policy.discountType == DiscountType.percent;

    return SizedBox(
      width: double.infinity,
      height: 120.h,
      child: Row(
        children: [
          // 왼쪽 할인 표시 부분
          _buildCouponLeft(isPercent: isPercent),
          // 오른쪽 쿠폰 정보 부분
          Expanded(
            child: _buildCouponRight(),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponLeft({
    required bool isPercent,
  }) {
    final textColor = isExpired ? const Color(0xFFC2C2C2) : Colors.white;

    NumberFormat.decimalPattern('ko_KR');
    final discountFormatValue =
        NumberFormat.decimalPattern().format(policy.discountValue);

    final percentColors = List.of(
        [V2MITIColor.primary2, V2MITIColor.primary3, V2MITIColor.primary5]);

    final fixedColors = List.of(
        [V2MITIColor.purple2, V2MITIColor.purple3, V2MITIColor.purple5]);

    final expiredColors =
        List.of([V2MITIColor.gray11, V2MITIColor.gray8, V2MITIColor.gray7]);

    final backgroundColors = isExpired
        ? expiredColors
        : isPercent
            ? fixedColors
            : percentColors;

    final couponTextColor = isExpired
        ? V2MITIColor.gray3
        : isPercent
            ? V2MITIColor.white
            : V2MITIColor.black;

    return SizedBox(
      width: 170.w,
      height: 120.h,
      child: Stack(
        children: [
          // 백그라운드 패턴 (옵션)
          Positioned.fill(
            child: ClipPath(
              child: _CouponBackground(
                colors: backgroundColors,
              ),
            ),
          ),
          // 텍스트 내용
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DISCOUNT',
                  style: V2MITITextStyle.poppinsMs
                      .copyWith(color: couponTextColor),
                ),
                SizedBox(height: 2.h),
                if (isPercent) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${policy.discountValue}',
                        style: V2MITITextStyle.freemanL
                            .copyWith(color: couponTextColor),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '%',
                        style: V2MITITextStyle.freemanMS
                            .copyWith(color: couponTextColor),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'OFF',
                        style: V2MITITextStyle.freemanMS
                            .copyWith(color: couponTextColor),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        discountFormatValue,
                        style: V2MITITextStyle.freemanM
                            .copyWith(color: couponTextColor),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '₩',
                        style: V2MITITextStyle.freemanMS
                            .copyWith(color: couponTextColor),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 쿠폰 이름
        Text(
          policy.name,
          style: V2MITITextStyle.largeBoldNormal
              .copyWith(color: V2MITIColor.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        // 쿠폰 상세 정보
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최대 ${policy.maxDiscountAmount}원 할인',
              style: V2MITITextStyle.miniMediumNormal
                  .copyWith(color: V2MITIColor.gray5),
            ),
            SizedBox(height: 4.h),
            Text(
              '유효기간: ${DateFormat('yyyy년 MM월 dd일').format(validUntil)}',
              style: V2MITITextStyle.miniMediumNormal
                  .copyWith(color: V2MITIColor.gray5),
            ),
          ],
        ),
      ],
    );
  }
}

class _CouponBackground extends StatelessWidget {
  final List<Color> colors;

  const _CouponBackground({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    colors
        .mapIndexed(
          (idx, c) => _buildRotatedContainer(
            left: -45.w + idx * -20.w,
            color: c,
          ),
        )
        .toList();

    return Stack(
        clipBehavior: Clip.none,
        children: colors
            .mapIndexed(
              (idx, c) => _buildRotatedContainer(
                left: -45.w + idx * -20.w,
                color: c,
              ),
            )
            .toList());
  }

  Widget _buildRotatedContainer({
    required double left,
    required Color color,
  }) {
    return Positioned(
      left: left,
      top: -100.h,
      child: Transform.rotate(
        angle: 20 * math.pi / 180,
        child: Container(
          width: 170.w,
          height: 400.h,
          color: color,
        ),
      ),
    );
  }
}
