import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';

part 'base_coupon_policy_response.g.dart';

@JsonSerializable()
class BaseCouponPolicyResponse extends IModelWithId {
  final String name;
  @JsonKey(name: 'target_item_type')
  final ItemType targetItemType;
  @JsonKey(name: 'discount_type')
  final DiscountType discountType;
  @JsonKey(name: 'discount_value')
  final int discountValue;
  @JsonKey(name: 'max_discount_amount')
  final int maxDiscountAmount;

  BaseCouponPolicyResponse({
    required super.id,
    required this.name,
    required this.targetItemType,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscountAmount,
  });

  factory BaseCouponPolicyResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseCouponPolicyResponseFromJson(json);

  BaseCouponPolicyResponse copyWith({
    int? id,
    String? name,
    ItemType? targetItemType,
    DiscountType? discountType,
    int? discountValue,
    int? maxDiscountAmount,
  }) {
    return BaseCouponPolicyResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      targetItemType: targetItemType ?? this.targetItemType,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
    );
  }
}
