import 'package:json_annotation/json_annotation.dart';

part 'expected_settlement_amount.g.dart';

@JsonSerializable()
class ExpectedSettlementAmount {
  @JsonKey(name: 'expected_settlement_amount')
  final int expectedSettlementAmount;

  ExpectedSettlementAmount({
    required this.expectedSettlementAmount,
  });

  factory ExpectedSettlementAmount.fromJson(Map<String, dynamic> json) =>
      _$ExpectedSettlementAmountFromJson(json);

  Map<String, dynamic> toJson() => _$ExpectedSettlementAmountToJson(this);

  ExpectedSettlementAmount copyWith({
    int? expectedSettlementAmount,
  }) {
    return ExpectedSettlementAmount(
      expectedSettlementAmount: expectedSettlementAmount ?? this.expectedSettlementAmount,
    );
  }
}
