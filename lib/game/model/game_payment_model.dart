import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../common/model/entity_enum.dart';
import '../../court/model/court_model.dart';

part 'game_payment_model.g.dart';

@JsonSerializable()
class GamePaymentModel extends IModelWithId {
  final CourtGameModel court;
  final GameStatus game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final int min_invitation;
  final int max_invitation;
  final String info;
  final PaymentModel payment_information;
  final int num_of_confirmed_participations;

  GamePaymentModel({
    required super.id,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.min_invitation,
    required this.max_invitation,
    required this.info,
    required this.num_of_confirmed_participations,
    required this.court,

    required this.payment_information,
  });

  factory GamePaymentModel.fromJson(Map<String, dynamic> json) =>
      _$GamePaymentModelFromJson(json);
}

@JsonSerializable()
class PaymentModel {
  final PaymentFeeModel payment_amount;
  final DiscountFeeModel discount_amount;
  final int final_payment_amount;

  PaymentModel({
    required this.payment_amount,
    required this.discount_amount,
    required this.final_payment_amount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
}


@JsonSerializable()
class PaymentFeeModel {
  final int game_fee_amount;
  final int commission_amount;
  final int vat_amount;
  final int total_amount;

  PaymentFeeModel({
    required this.game_fee_amount,
    required this.commission_amount,
    required this.vat_amount,
    required this.total_amount,
  });

  factory PaymentFeeModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentFeeModelFromJson(json);
}
@JsonSerializable()
class DiscountFeeModel {
  final int promotion_amount;
  final int total_amount;

  DiscountFeeModel({
    required this.promotion_amount,
    required this.total_amount,
  });

  factory DiscountFeeModel.fromJson(Map<String, dynamic> json) =>
      _$DiscountFeeModelFromJson(json);
}

@JsonSerializable()
class RefundModel {
  final int quantity;
  final ItemType item_type;
  final String partner_order_id;
  final String partner_user_id;
  final RefundPaymentModel payment_amount;
  final RefundCommissionModel commission_amount;
  final int final_refund_amount;


  RefundModel({
    required this.quantity,
    required this.item_type,
    required this.partner_order_id,
    required this.partner_user_id,
    required this.payment_amount,
    required this.commission_amount,
    required this.final_refund_amount,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) =>
      _$RefundModelFromJson(json);
}

@JsonSerializable()
class RefundPaymentModel {
  final int total_amount;
  final int vat_amount;
  final int tax_free_amount;
  final int point_amount;
  final int discount_amount;
  final int green_deposit_amount;


  RefundPaymentModel({
    required this.total_amount,
    required this.vat_amount,
    required this.tax_free_amount,
    required this.point_amount,
    required this.discount_amount,
    required this.green_deposit_amount,
  });

  factory RefundPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$RefundPaymentModelFromJson(json);
}

@JsonSerializable()
class RefundCommissionModel {
  final int payment_commission_amount;
  final int cancelation_commission_amount;
  final int total_amount;



  RefundCommissionModel({
    required this.payment_commission_amount,
    required this.cancelation_commission_amount,
    required this.total_amount,
  });

  factory RefundCommissionModel.fromJson(Map<String, dynamic> json) =>
      _$RefundCommissionModelFromJson(json);
}