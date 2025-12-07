import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'payment_result_response.g.dart';

@JsonSerializable()
class PaymentResultResponse extends IModelWithId {
  @JsonKey(name: 'status')
  final PaymentResultStatusType status;

  @JsonKey(name: 'item_type')
  final ItemType itemType;

  @JsonKey(name: 'item_name')
  final String itemName;

  @JsonKey(name: 'payment_method')
  final PaymentMethodType paymentMethod;

  @JsonKey(name: 'origin_amount')
  final int? originAmount;

  @JsonKey(name: 'tax_free_amount')
  final int taxFreeAmount;

  @JsonKey(name: 'vat_amount')
  final int vatAmount;

  @JsonKey(name: 'point_amount')
  final int? pointAmount;

  @JsonKey(name: 'discount_amount')
  final int? discountAmount;

  @JsonKey(name: 'final_amount')
  final int finalAmount;

  @JsonKey(name: 'cancelation_reason')
  final PaymentCancelationReason? cancelationReason;

  @JsonKey(name: 'canceled_vat_amount')
  final int? canceledVatAmount;

  @JsonKey(name: 'canceled_point_amount')
  final int? canceledPointAmount;

  @JsonKey(name: 'canceled_final_amount')
  final int? canceledFinalAmount;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'approved_at')
  final DateTime? approvedAt;

  @JsonKey(name: 'canceled_at')
  final DateTime? canceledAt;

  @JsonKey(name: 'failed_at')
  final DateTime? failedAt;

  PaymentResultResponse({
    required super.id,
    required this.status,
    required this.itemType,
    required this.itemName,
    required this.paymentMethod,
     this.originAmount,
    required this.taxFreeAmount,
    required this.vatAmount,
     this.pointAmount,
     this.discountAmount,
    required this.finalAmount,
    this.cancelationReason,
    this.canceledVatAmount,
    this.canceledPointAmount,
    this.canceledFinalAmount,
    required this.createdAt,
    this.approvedAt,
    this.canceledAt,
    this.failedAt,
  });

  factory PaymentResultResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResultResponseToJson(this);

  PaymentResultResponse copyWith({
    int? id,
    PaymentResultStatusType? status,
    ItemType? itemType,
    String? itemName,
    PaymentMethodType? paymentMethod,
    int? originAmount,
    int? taxFreeAmount,
    int? vatAmount,
    int? pointAmount,
    int? discountAmount,
    int? finalAmount,
    PaymentCancelationReason? cancelationReason,
    int? canceledVatAmount,
    int? canceledPointAmount,
    int? canceledFinalAmount,
    DateTime? createdAt,
    DateTime? approvedAt,
    DateTime? canceledAt,
    DateTime? failedAt,
  }) {
    return PaymentResultResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      itemType: itemType ?? this.itemType,
      itemName: itemName ?? this.itemName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      originAmount: originAmount ?? this.originAmount,
      taxFreeAmount: taxFreeAmount ?? this.taxFreeAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      pointAmount: pointAmount ?? this.pointAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      cancelationReason: cancelationReason ?? this.cancelationReason,
      canceledVatAmount: canceledVatAmount ?? this.canceledVatAmount,
      canceledPointAmount: canceledPointAmount ?? this.canceledPointAmount,
      canceledFinalAmount: canceledFinalAmount ?? this.canceledFinalAmount,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      canceledAt: canceledAt ?? this.canceledAt,
      failedAt: failedAt ?? this.failedAt,
    );
  }
}
