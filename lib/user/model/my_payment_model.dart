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

@JsonSerializable()
class MyPaymentModel extends IModelWithId {
  final PaymentResultType status;
  final ItemType item_type;
  final PaymentMethodType payment_method;
  final PaymentCancelType? cancelation_reason;
  final String created_at;
  final String approved_at;
  final int total_amount;
  final String partner_order_id;

  MyPaymentModel({
    required super.id,
    required this.status,
    required this.item_type,
    required this.payment_method,
    required this.cancelation_reason,
    required this.created_at,
    required this.approved_at,
    required this.total_amount,
    required this.partner_order_id,
  });

  factory MyPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$MyPaymentModelFromJson(json);
}
