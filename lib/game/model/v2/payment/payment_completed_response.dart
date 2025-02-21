import 'package:json_annotation/json_annotation.dart';

import '../../../../common/model/entity_enum.dart';

part 'payment_completed_response.g.dart';

@JsonSerializable()
class PaymentCompletedResponse {
  @JsonKey(name: 'status')
  final PaymentResultStatusType status;

  @JsonKey(name: 'payment_method')
  final PaymentMethodType paymentMethod;

  @JsonKey(name: 'total_amount')
  final int totalAmount;

  @JsonKey(name: 'tax_free_amount')
  final int taxFreeAmount;

  @JsonKey(name: 'vat_amount')
  final int vatAmount;

  @JsonKey(name: 'approved_at')
  final DateTime approvedAt;

  PaymentCompletedResponse({
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.taxFreeAmount,
    required this.vatAmount,
    required this.approvedAt,
  });

  factory PaymentCompletedResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentCompletedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCompletedResponseToJson(this);

  PaymentCompletedResponse copyWith({
    PaymentResultStatusType? status,
    PaymentMethodType? paymentMethod,
    int? totalAmount,
    int? taxFreeAmount,
    int? vatAmount,
    DateTime? approvedAt,
  }) {
    return PaymentCompletedResponse(
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalAmount: totalAmount ?? this.totalAmount,
      taxFreeAmount: taxFreeAmount ?? this.taxFreeAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
