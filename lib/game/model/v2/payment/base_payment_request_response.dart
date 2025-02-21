import 'package:json_annotation/json_annotation.dart';

import '../../../../common/model/entity_enum.dart';

part 'base_payment_request_response.g.dart';

@JsonSerializable()
class BasePaymentRequestResponse {
  final int id;

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'item_type')
  final ItemType itemType;

  @JsonKey(name: 'item_name')
  final String itemName;

  @JsonKey(name: 'total_amount')
  final int totalAmount;

  @JsonKey(name: 'tax_free_amount')
  final int taxFreeAmount;

  @JsonKey(name: 'vat_amount')
  final int vatAmount;

  BasePaymentRequestResponse({
    required this.id,
    required this.orderId,
    required this.itemType,
    required this.itemName,
    required this.totalAmount,
    required this.taxFreeAmount,
    required this.vatAmount,
  });

  factory BasePaymentRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$BasePaymentRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BasePaymentRequestResponseToJson(this);

  BasePaymentRequestResponse copyWith({
    int? id,
    String? orderId,
    ItemType? itemType,
    String? itemName,
    int? totalAmount,
    int? taxFreeAmount,
    int? vatAmount,
  }) {
    return BasePaymentRequestResponse(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      itemType: itemType ?? this.itemType,
      itemName: itemName ?? this.itemName,
      totalAmount: totalAmount ?? this.totalAmount,
      taxFreeAmount: taxFreeAmount ?? this.taxFreeAmount,
      vatAmount: vatAmount ?? this.vatAmount,
    );
  }
}
