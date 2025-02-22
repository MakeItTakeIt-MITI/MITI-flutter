import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'payment_result_response.g.dart';

@JsonSerializable()
class PaymentResultResponse extends IModelWithId {
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

  @JsonKey(name: 'tax_free_amount')
  final int taxFreeAmount;

  @JsonKey(name: 'canceled_total_amount')
  final int? canceledTotalAmount;

  @JsonKey(name: 'canceled_tax_free_amount')
  final int? canceledTaxFreeAmount;

  @JsonKey(name: 'approved_at')
  final String approvedAt;

  @JsonKey(name: 'canceled_at')
  final String? canceledAt;

  PaymentResultResponse({
    required super.id,
    required this.itemType,
    required this.status,
    required this.paymentMethod,
    required this.quantity,
    required this.itemName,
    required this.totalAmount,
    required this.taxFreeAmount,
    this.canceledTotalAmount,
    this.canceledTaxFreeAmount,
    required this.approvedAt,
    this.canceledAt,
  });

  factory PaymentResultResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResultResponseToJson(this);

  PaymentResultResponse copyWith({
    int? id,
    ItemType? itemType,
    PaymentResultStatusType? status,
    PaymentMethodType? paymentMethod,
    int? quantity,
    String? itemName,
    int? totalAmount,
    int? taxFreeAmount,
    int? canceledTotalAmount,
    int? canceledTaxFreeAmount,
    String? approvedAt,
    String? canceledAt,
  }) {
    return PaymentResultResponse(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      quantity: quantity ?? this.quantity,
      itemName: itemName ?? this.itemName,
      totalAmount: totalAmount ?? this.totalAmount,
      taxFreeAmount: taxFreeAmount ?? this.taxFreeAmount,
      canceledTotalAmount: canceledTotalAmount ?? this.canceledTotalAmount,
      canceledTaxFreeAmount:
          canceledTaxFreeAmount ?? this.canceledTaxFreeAmount,
      approvedAt: approvedAt ?? this.approvedAt,
      canceledAt: canceledAt ?? this.canceledAt,
    );
  }
}
