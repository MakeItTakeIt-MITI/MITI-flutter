import 'package:json_annotation/json_annotation.dart';

part 'payment_amount.g.dart';

@JsonSerializable()
class PaymentAmount {
  @JsonKey(name: 'total_amount')
  final int totalAmount;

  @JsonKey(name: 'tax_free_amount')
  final int taxFreeAmount;

  @JsonKey(name: 'vat_amount')
  final int vatAmount;

  @JsonKey(name: 'point_amount', includeIfNull: false)
  final int? pointAmount;

  @JsonKey(name: 'discount_amount', includeIfNull: false)
  final int? discountAmount;

  @JsonKey(name: 'green_deposit_amount', includeIfNull: false)
  final int? greenDepositAmount;

  PaymentAmount({
    required this.totalAmount,
    required this.taxFreeAmount,
    required this.vatAmount,
    this.pointAmount,
    this.discountAmount,
    this.greenDepositAmount,
  });

  factory PaymentAmount.fromJson(Map<String, dynamic> json) =>
      _$PaymentAmountFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAmountToJson(this);

  PaymentAmount copyWith({
    int? totalAmount,
    int? taxFreeAmount,
    int? vatAmount,
    int? pointAmount,
    int? discountAmount,
    int? greenDepositAmount,
  }) {
    return PaymentAmount(
      totalAmount: totalAmount ?? this.totalAmount,
      taxFreeAmount: taxFreeAmount ?? this.taxFreeAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      pointAmount: pointAmount ?? this.pointAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      greenDepositAmount: greenDepositAmount ?? this.greenDepositAmount,
    );
  }
}
