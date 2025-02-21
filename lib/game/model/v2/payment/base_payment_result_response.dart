import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../../common/model/entity_enum.dart';

part 'base_payment_result_response.g.dart';

@JsonSerializable()
class BasePaymentResultResponse extends IModelWithId{

  @JsonKey(name: 'item_type')
  final ItemType itemType;

  @JsonKey(name: 'status')
  final PaymentResultStatusType status;

  @JsonKey(name: 'payment_method')
  final PaymentMethodType paymentMethod;

  @JsonKey(name: 'quantity')
  final int quantity;

  @JsonKey(name: 'item_name')
  final String itemName;

  @JsonKey(name: 'total_amount')
  final int totalAmount;

  @JsonKey(name: 'approved_at')
  final DateTime approvedAt;

  BasePaymentResultResponse({
    required super.id,
    required this.itemType,
    required this.status,
    required this.paymentMethod,
    required this.quantity,
    required this.itemName,
    required this.totalAmount,
    required this.approvedAt,
  });

  factory BasePaymentResultResponse.fromJson(Map<String, dynamic> json) =>
      _$BasePaymentResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BasePaymentResultResponseToJson(this);

  BasePaymentResultResponse copyWith({
    int? id,
    ItemType? itemType,
    PaymentResultStatusType? status,
    PaymentMethodType? paymentMethod,
    int? quantity,
    String? itemName,
    int? totalAmount,
    DateTime? approvedAt,
  }) {
    return BasePaymentResultResponse(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      quantity: quantity ?? this.quantity,
      itemName: itemName ?? this.itemName,
      totalAmount: totalAmount ?? this.totalAmount,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
