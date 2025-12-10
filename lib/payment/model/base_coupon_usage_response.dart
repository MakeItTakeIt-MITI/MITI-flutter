import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_coupon_usage_response.g.dart';

@JsonSerializable()
class BaseCouponUsageResponse extends IModelWithId {
  /// 쿠폰 이름
  final String name;

  /// 쿠폰 상태
  final CouponStatusType status;

  /// 쿠폰 사용 가능 품목
  @JsonKey(name: 'target_item_type')
  final ItemType targetItemType;

  /// 할인 유형
  @JsonKey(name: 'discount_type')
  final DiscountType discountType;

  /// 할인 값
  @JsonKey(name: 'discount_value')
  final int discountValue;

  /// 최대 할인 금액
  @JsonKey(name: 'max_discount_amount')
  final int? maxDiscountAmount;

  /// 최종 적용 할인 금액
  @JsonKey(name: 'discount_amount')
  final int discountAmount;

  /// 쿠폰 발행일
  @JsonKey(name: 'issued_at')
  final DateTime issuedAt;

  /// 유효 시작일
  @JsonKey(name: 'valid_from')
  final DateTime? validFrom;

  /// 유효 마감일 (null 반환 가능)
  @JsonKey(name: 'valid_until')
  final DateTime? validUntil;

  BaseCouponUsageResponse({
    required super.id,
    required this.name,
    required this.status,
    required this.targetItemType,
    required this.discountType,
    required this.discountValue,
     this.maxDiscountAmount,
    required this.discountAmount,
    required this.issuedAt,
     this.validFrom,
    this.validUntil,
  });

  factory BaseCouponUsageResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseCouponUsageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseCouponUsageResponseToJson(this);

  // 선택 사항: copyWith 메서드 추가
  BaseCouponUsageResponse copyWith({
    int? id,
    String? name,
    CouponStatusType? status,
    ItemType? targetItemType,
    DiscountType? discountType,
    int? discountValue,
    int? maxDiscountAmount,
    int? discountAmount,
    DateTime? issuedAt,
    DateTime? validFrom,
    DateTime? validUntil,
  }) {
    return BaseCouponUsageResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      targetItemType: targetItemType ?? this.targetItemType,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      issuedAt: issuedAt ?? this.issuedAt,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
    );
  }
}
