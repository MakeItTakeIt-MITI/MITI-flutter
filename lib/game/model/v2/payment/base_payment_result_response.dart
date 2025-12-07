import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../../common/model/entity_enum.dart';

part 'base_payment_result_response.g.dart';

@JsonSerializable()
class BasePaymentResultResponse extends IModelWithId {

  @JsonKey(name: 'status')
  final PaymentResultStatusType status;

  @JsonKey(name: 'item_type')
  final ItemType itemType;

  @JsonKey(name: 'item_name')
  final String itemName;

  @JsonKey(name: 'payment_method')
  final PaymentMethodType paymentMethod;

  @JsonKey(name: 'final_amount')
  final int finalAmount;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'approved_at')
  final DateTime approvedAt;

  BasePaymentResultResponse({
    required super.id,
    required this.status,
    required this.itemType,
    required this.itemName,
    required this.paymentMethod,
    required this.finalAmount,
    required this.createdAt,
    required this.approvedAt,
  });

  factory BasePaymentResultResponse.fromJson(Map<String, dynamic> json) =>
      _$BasePaymentResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BasePaymentResultResponseToJson(this);

  BasePaymentResultResponse copyWith({
    int? id,
    PaymentResultStatusType? status,
    ItemType? itemType,
    String? itemName,
    PaymentMethodType? paymentMethod,
    int? finalAmount,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return BasePaymentResultResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      itemType: itemType ?? this.itemType,
      itemName: itemName ?? this.itemName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      finalAmount: finalAmount ?? this.finalAmount,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
