import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_coupon_info_response.g.dart';

@JsonSerializable()
class BaseCouponInfoResponse extends IModelWithId {
  @JsonKey(name: 'status')
  final CouponStatusType status;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'valid_from')
  final DateTime? validFrom;

  @JsonKey(name: 'valid_until')
  final DateTime? validUntil;

  @JsonKey(name: 'target_item_type')
  final String targetItemType;

  @JsonKey(name: 'discount_value')
  final int discountValue;

  @JsonKey(name: 'coupon_discount_amount')
  final int couponDiscountAmount;

  @JsonKey(name: 'coupon_max_discount_amount')
  final int couponMaxDiscountAmount;

  @JsonKey(name: 'coupon_final_discount_amount')
  final int couponFinalDiscountAmount;

  BaseCouponInfoResponse({
    required super.id,
    required this.status,
    required this.name,
    this.validFrom,
    this.validUntil,
    required this.targetItemType,
    required this.discountValue,
    required this.couponDiscountAmount,
    required this.couponMaxDiscountAmount,
    required this.couponFinalDiscountAmount,
  });

  factory BaseCouponInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseCouponInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseCouponInfoResponseToJson(this);

  BaseCouponInfoResponse copyWith({
    int? id,
    CouponStatusType? status,
    String? name,
    DateTime? validFrom,
    DateTime? validUntil,
    String? targetItemType,
    int? discountValue,
    int? couponDiscountAmount,
    int? couponMaxDiscountAmount,
    int? couponFinalDiscountAmount,
  }) {
    return BaseCouponInfoResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      name: name ?? this.name,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      targetItemType: targetItemType ?? this.targetItemType,
      discountValue: discountValue ?? this.discountValue,
      couponDiscountAmount: couponDiscountAmount ?? this.couponDiscountAmount,
      couponMaxDiscountAmount: couponMaxDiscountAmount ?? this.couponMaxDiscountAmount,
      couponFinalDiscountAmount: couponFinalDiscountAmount ?? this.couponFinalDiscountAmount,
    );
  }
}
