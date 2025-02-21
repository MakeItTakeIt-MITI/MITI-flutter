import 'package:json_annotation/json_annotation.dart';

part 'base_game_participation_discount_amount.g.dart';

@JsonSerializable()
class BaseGameParticipationDiscountAmount {
  @JsonKey(name: 'promotion_amount')
  final int promotionAmount;

  @JsonKey(name: 'total_amount')
  final int totalAmount;

  BaseGameParticipationDiscountAmount({
    required this.promotionAmount,
    required this.totalAmount,
  });

  factory BaseGameParticipationDiscountAmount.fromJson(Map<String, dynamic> json) =>
      _$BaseGameParticipationDiscountAmountFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameParticipationDiscountAmountToJson(this);

  // CopyWith method
  BaseGameParticipationDiscountAmount copyWith({
    int? promotionAmount,
    int? totalAmount,
  }) {
    return BaseGameParticipationDiscountAmount(
      promotionAmount: promotionAmount ?? this.promotionAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}