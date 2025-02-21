import 'package:json_annotation/json_annotation.dart';

part 'refund_commission_amount.g.dart';

@JsonSerializable()
class RefundCommissionAmount {
  @JsonKey(name: 'payment_commission_amount')
  final int paymentCommissionAmount;

  @JsonKey(name: 'cancelation_commission_amount')
  final int cancelationCommissionAmount;

  @JsonKey(name: 'total_amount')
  final int totalAmount;

  RefundCommissionAmount({
    required this.paymentCommissionAmount,
    required this.cancelationCommissionAmount,
    required this.totalAmount,
  });

  factory RefundCommissionAmount.fromJson(Map<String, dynamic> json) =>
      _$RefundCommissionAmountFromJson(json);

  Map<String, dynamic> toJson() => _$RefundCommissionAmountToJson(this);

  RefundCommissionAmount copyWith({
    int? paymentCommissionAmount,
    int? cancelationCommissionAmount,
    int? totalAmount,
  }) {
    return RefundCommissionAmount(
      paymentCommissionAmount: paymentCommissionAmount ?? this.paymentCommissionAmount,
      cancelationCommissionAmount: cancelationCommissionAmount ?? this.cancelationCommissionAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
