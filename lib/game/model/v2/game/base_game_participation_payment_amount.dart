import 'package:json_annotation/json_annotation.dart';

part 'base_game_participation_payment_amount.g.dart';

@JsonSerializable()
class BaseGameParticipationPaymentAmount {
  @JsonKey(name: 'game_fee_amount')
  final int gameFeeAmount;

  @JsonKey(name: 'vat_amount')
  final int vatAmount;

  @JsonKey(name: 'tax_free_amount')
  final int taxFreeAmount;

  @JsonKey(name: 'commission_amount')
  final int commissionAmount;

  @JsonKey(name: 'total_amount')
  final int totalAmount;

  BaseGameParticipationPaymentAmount({
    required this.gameFeeAmount,
    required this.vatAmount,
    required this.taxFreeAmount,
    required this.commissionAmount,
    required this.totalAmount,
  });

  factory BaseGameParticipationPaymentAmount.fromJson(Map<String, dynamic> json) =>
      _$BaseGameParticipationPaymentAmountFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameParticipationPaymentAmountToJson(this);

  // CopyWith method
  BaseGameParticipationPaymentAmount copyWith({
    int? gameFeeAmount,
    int? vatAmount,
    int? taxFreeAmount,
    int? commissionAmount,
    int? totalAmount,
  }) {
    return BaseGameParticipationPaymentAmount(
      gameFeeAmount: gameFeeAmount ?? this.gameFeeAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      taxFreeAmount: taxFreeAmount ?? this.taxFreeAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}