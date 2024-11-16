import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

part 'boot_pay_approve_model.g.dart';

@JsonSerializable()
class BootPayApproveModel {
  final PaymentResultStatus status;
  @JsonKey(name: 'payment_method')
  final PaymentMethodType paymentMethod;
  @JsonKey(name: 'total_amount')
  final int totalAmount;
  @JsonKey(name: 'tax_free_amount')
  final int taxFreeAmount;
  @JsonKey(name: 'vat_amount')
  final int vatAmount;
  @JsonKey(name: 'approved_at')
  final String approvedAt;

  BootPayApproveModel({
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.taxFreeAmount,
    required this.vatAmount,
    required this.approvedAt,
  });

  factory BootPayApproveModel.fromJson(Map<String, dynamic> json) =>
      _$BootPayApproveModelFromJson(json);
}
