/*
"id": 102,
"status": "approved",
"item_type": "pickup_game",
"payment_method": "kakao_pay",
"cancelation_reason": null,
"created_at": "2024-08-14T23:45:29.498361+09:00",
"approved_at": "2024-08-14T23:45:29+09:00",
"total_amount": 10000,
"partner_order_id": "PG_21131_2"
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'my_payment_model.g.dart';

/*
"id": 73,
"item_type": "pickup_game",
"status": "approved",
"quantity": 1,
"item_name": "경기참가비 [MITI 픽업게임]",
"payment_method": "kakao",
"total_amount": 1000,
"tax_free_amount": 1000,
"canceled_total_amount": null,
"canceled_tax_free_amount": null,
"approved_at": "2024-11-21T16:07:13.675888+09:00",
"canceled_at": null
 */
@JsonSerializable()
class MyPaymentDetailModel extends IModelWithId {
  final ItemType item_type;
  final PaymentResultType status;
  final int quantity;
  final String item_name;
  final PaymentMethodType payment_method;
  final int total_amount;
  final int tax_free_amount;
  final int? canceled_total_amount;
  final int? canceled_tax_free_amount;
  final String approved_at;
  final String? canceled_at;

  MyPaymentDetailModel({
    required super.id,
    required this.item_type,
    required this.status,
    required this.quantity,
    required this.item_name,
    required this.payment_method,
    required this.total_amount,
    required this.tax_free_amount,
    required this.canceled_total_amount,
    required this.canceled_tax_free_amount,
    required this.approved_at,
    required this.canceled_at,
  });

  factory MyPaymentDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MyPaymentDetailModelFromJson(json);
}

@JsonSerializable()
class MyPaymentModel extends IModelWithId {
  final PaymentResultType status;
  final ItemType item_type;
  final String item_name;
  final PaymentMethodType payment_method;
  // final String order_id;
  final int total_amount;
  final int tax_free_amount;
  final int? canceled_total_amount;
  final int? canceled_tax_free_amount;
  final PaymentCancelType? cancelation_reason;
  final String approved_at;
  final String? canceled_at;

  MyPaymentModel({
    required super.id,
    required this.status,
    required this.item_type,
    required this.payment_method,
    // required this.order_id,
    required this.item_name,
    required this.total_amount,
    required this.tax_free_amount,
    required this.canceled_total_amount,
    required this.canceled_tax_free_amount,
    required this.cancelation_reason,
    required this.approved_at,
    required this.canceled_at,
  });

  factory MyPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$MyPaymentModelFromJson(json);
}
