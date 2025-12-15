import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import 'base_coupon_policy_response.dart';

part 'coupon_response.g.dart';

@JsonSerializable()
class CouponResponse extends IModelWithId {
  final CouponStatusType status;

  @JsonKey(name: 'issued_at')
  final DateTime issuedAt;

  @JsonKey(name: 'valid_from')
  final DateTime validFrom;

  @JsonKey(name: 'valid_until')
  final DateTime validUntil;

  final BaseCouponPolicyResponse policy;

  CouponResponse({
    required super.id,
    required this.status,
    required this.issuedAt,
    required this.validFrom,
    required this.validUntil,
    required this.policy,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponResponseFromJson(json);

  CouponResponse copyWith({
    int? id,
    CouponStatusType? status,
    DateTime? issuedAt,
    DateTime? validFrom,
    DateTime? validUntil,
    BaseCouponPolicyResponse? policy,
  }) {
    return CouponResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      issuedAt: issuedAt ?? this.issuedAt,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      policy: policy ?? this.policy,
    );
  }
}
