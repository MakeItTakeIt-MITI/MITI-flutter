import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:miti/game/base_coupon_info_response.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/entity_enum.dart';
import '../../util/util.dart';

class CouponSelection extends StatefulWidget {
  final int? selectedId;
  final List<BaseCouponInfoResponse> coupons;
  final Function(BaseCouponInfoResponse) onSelect;

  const CouponSelection(
      {super.key,
      required this.coupons,
      required this.onSelect,
      required this.selectedId});

  @override
  State<CouponSelection> createState() => _CouponSelectionState();
}

class _CouponSelectionState extends State<CouponSelection> {
  late CarouselSliderController carouselController;
  int currentIdx = 0;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12.h,
      children: [
        Row(
          spacing: 12.w,
          children: [
            Text(
              "사용 가능한 쿠폰",
              style: V2MITITextStyle.smallRegular
                  .copyWith(color: V2MITIColor.gray1),
            ),
            Container(
              decoration: BoxDecoration(
                color: V2MITIColor.gray8,
                borderRadius: BorderRadius.circular(
                  100.r,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.h),
              child: Text(
                "${widget.coupons.length}장",
                style: V2MITITextStyle.miniBoldTight
                    .copyWith(color: V2MITIColor.primary4),
              ),
            )
          ],
        ),
        CarouselSlider(
          carouselController: carouselController,
          options: CarouselOptions(
              enlargeCenterPage: true,
              viewportFraction: 1,
              // height: 140.h,
              aspectRatio: 2.5,
              enlargeFactor: 0,
              initialPage: 0,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              enableInfiniteScroll: false,
              animateToClosest: false,
              onPageChanged: (idx, _) {
                setState(() {
                  currentIdx = idx;
                  log('currentIdx = $currentIdx');
                });
              }),
          items: widget.coupons.mapIndexed((idx, coupon) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => widget.onSelect(coupon),
                  child: CouponCard.fromModel(
                      model: coupon,
                      isSelected: widget.selectedId == coupon.id),
                );
              },
            );
          }).toList(),
        )
      ],
    );
  }
}

class CouponCard extends StatelessWidget {
  final int id;
  final CouponStatusType status;
  final String name;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String targetItemType;
  final int discountValue;
  final int couponDiscountAmount;
  final int couponMaxDiscountAmount;
  final int couponFinalDiscountAmount;
  final bool isSelected;

  const CouponCard({
    super.key,
    required this.status,
    required this.name,
    this.validFrom,
    this.validUntil,
    required this.targetItemType,
    required this.discountValue,
    required this.couponDiscountAmount,
    required this.couponMaxDiscountAmount,
    required this.couponFinalDiscountAmount,
    required this.isSelected,
    required this.id,
  });

  factory CouponCard.fromModel(
      {required BaseCouponInfoResponse model, required bool isSelected}) {
    return CouponCard(
      status: model.status,
      name: model.name,
      validFrom: model.validFrom,
      validUntil: model.validUntil,
      targetItemType: model.targetItemType,
      discountValue: model.discountValue,
      couponDiscountAmount: model.couponDiscountAmount,
      couponMaxDiscountAmount: model.couponMaxDiscountAmount,
      couponFinalDiscountAmount: model.couponFinalDiscountAmount,
      isSelected: isSelected,
      id: model.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 헤더
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.vertical(
              top: Radius.circular(16.r),
            ),
            color: isSelected ? V2MITIColor.primary5 : V2MITIColor.gray11,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name,
                style: V2MITITextStyle.smallMediumNormal.copyWith(
                    color: isSelected ? V2MITIColor.gray11 : V2MITIColor.gray1),
              ),
              Text(
                '$discountValue원 할인쿠폰',
                style: V2MITITextStyle.largeBoldNormal.copyWith(
                    color: isSelected ? V2MITIColor.black : V2MITIColor.white),
              )
            ],
          ),
        ),
        // body
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.vertical(
              bottom: Radius.circular(16.r),
            ),
            border: Border.all(color: V2MITIColor.gray11),
            color: isSelected ? V2MITIColor.gray11 : Colors.transparent,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "${NumberFormat.decimalPattern().format(couponMaxDiscountAmount)}원",
                    style: V2MITITextStyle.smallMediumNormal
                        .copyWith(color: V2MITIColor.gray2),
                  ),
                  if (validUntil != null)
                    Text(
                      DateFormat('yyyy년 MM월 dd일').format(validUntil!),
                      style: V2MITITextStyle.largeBoldNormal
                          .copyWith(color: V2MITIColor.gray3),
                    )
                ],
              ),
              Visibility(
                visible: isSelected,
                child: SvgPicture.asset(
                  AssetUtil.getAssetPath(
                      type: AssetType.icon, name: "check_circle"),
                  height: 24.r,
                  width: 24.r,
                  colorFilter: const ColorFilter.mode(
                    V2MITIColor.primary5,
                    BlendMode.srcIn,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
