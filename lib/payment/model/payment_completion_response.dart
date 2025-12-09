import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'payment_completion_response.g.dart';

@JsonSerializable()
class PaymentCompletionResponse extends IModelWithId {

  final PaymentResultStatusType status;

  @JsonKey(name: 'item_type')
  final ItemType itemType;

  @JsonKey(name: 'item_name')
  final String itemName;

  @JsonKey(name: 'payment_method')
  final PaymentMethodType paymentMethod;

  @JsonKey(name: 'origin_amount')
  final int originAmount;

  @JsonKey(name: 'vat_amount')
  final int vatAmount;

  @JsonKey(name: 'discount_amount')
  final int discountAmount;

  @JsonKey(name: 'final_amount')
  final int finalAmount;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'approved_at')
  final DateTime approvedAt;

  PaymentCompletionResponse({
    required super.id,
    required this.status,
    required this.itemType,
    required this.itemName,
    required this.paymentMethod,
    required this.originAmount,
    required this.vatAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.createdAt,
    required this.approvedAt,
  });

  factory PaymentCompletionResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentCompletionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCompletionResponseToJson(this);

  PaymentCompletionResponse copyWith({
    int? id,
    PaymentResultStatusType? status,
    ItemType? itemType,
    String? itemName,
    PaymentMethodType? paymentMethod,
    int? originAmount,
    int? vatAmount,
    int? discountAmount,
    int? finalAmount,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return PaymentCompletionResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      itemType: itemType ?? this.itemType,
      itemName: itemName ?? this.itemName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      originAmount: originAmount ?? this.originAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
