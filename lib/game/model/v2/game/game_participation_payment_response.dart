import 'package:json_annotation/json_annotation.dart';

import 'base_game_participation_discount_amount.dart';
import 'base_game_participation_payment_amount.dart';

part 'game_participation_payment_response.g.dart';

@JsonSerializable()
class GameParticipationPaymentResponse {
  @JsonKey(name: 'payment_amount')
  final BaseGameParticipationPaymentAmount paymentAmount;

  @JsonKey(name: 'discount_amount')
  final BaseGameParticipationDiscountAmount discountAmount;

  @JsonKey(name: 'final_payment_amount')
  final int finalPaymentAmount;

  GameParticipationPaymentResponse({
    required this.paymentAmount,
    required this.discountAmount,
    required this.finalPaymentAmount,
  });

  factory GameParticipationPaymentResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GameParticipationPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GameParticipationPaymentResponseToJson(this);

  // CopyWith method
  GameParticipationPaymentResponse copyWith({
    BaseGameParticipationPaymentAmount? paymentAmount,
    BaseGameParticipationDiscountAmount? discountAmount,
    int? finalPaymentAmount,
  }) {
    return GameParticipationPaymentResponse(
      paymentAmount: paymentAmount ?? this.paymentAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalPaymentAmount: finalPaymentAmount ?? this.finalPaymentAmount,
    );
  }
}
