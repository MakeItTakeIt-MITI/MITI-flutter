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
    "id": 16,
    "status": "approved",
    "item_type": "pickup_game",
    "payment_method": "empty_pay",
    "order_id": "NXdXQTPcqhEjH5u3nE77QK",
    "total_amount": 0,
    "tax_free_amount": 0,
    "canceled_total_amount": null,
    "canceled_tax_free_amount": null,
    "cancelation_reason": null,
    "approved_at": "2024-11-18T00:29:52.923875+09:00",
    "canceled_at": null
 */
@JsonSerializable()
class MyPaymentModel extends IModelWithId {
  final PaymentResultType status;
  final ItemType item_type;
  final PaymentMethodType payment_method;
  final String item_name;
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
