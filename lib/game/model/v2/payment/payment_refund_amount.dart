import 'package:json_annotation/json_annotation.dart';
import 'payment_amount.dart'; // PaymentAmount 클래스 import
import 'refund_commission_amount.dart'; // RefundCommissionAmount 클래스 import

part 'payment_refund_amount.g.dart';

@JsonSerializable()
class PaymentRefundAmount {
  @JsonKey(name: 'payment_amount')
  final PaymentAmount paymentAmount;

  @JsonKey(name: 'refund_commission_amount')
  final RefundCommissionAmount refundCommissionAmount;

  @JsonKey(name: 'final_refund_amount')
  final int finalRefundAmount;

  PaymentRefundAmount({
    required this.paymentAmount,
    required this.refundCommissionAmount,
    required this.finalRefundAmount,
  });

  factory PaymentRefundAmount.fromJson(Map<String, dynamic> json) =>
      _$PaymentRefundAmountFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRefundAmountToJson(this);

  PaymentRefundAmount copyWith({
    PaymentAmount? paymentAmount,
    RefundCommissionAmount? refundCommissionAmount,
    int? finalRefundAmount,
  }) {
    return PaymentRefundAmount(
      paymentAmount: paymentAmount ?? this.paymentAmount,
      refundCommissionAmount: refundCommissionAmount ?? this.refundCommissionAmount,
      finalRefundAmount: finalRefundAmount ?? this.finalRefundAmount,
    );
  }
}
