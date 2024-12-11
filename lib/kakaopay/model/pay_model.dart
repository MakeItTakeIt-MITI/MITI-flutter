import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import 'boot_pay_request_model.dart';

part 'pay_model.g.dart';

@JsonSerializable()
class PayBaseModel {
  PayBaseModel();

  // 기본 fromJson 메소드
  factory PayBaseModel.fromJson(Map<String, dynamic> json) {
    // 타입을 구분할 수 있는 필드를 기준으로 적절한 서브클래스를 반환합니다.
    if (json.containsKey('order_id')) {
      log("PayReadyModel");
      return BootPayRequestModel.fromJson(json);
    } else if (json.containsKey('game')) {
      log("PayFreeModel");
      return PayFreeModel.fromJson(json);
    } else {
      // 필요한 경우 기본 PayBaseModel을 반환
      log("_PayBaseModelFromJson");

      return _$PayBaseModelFromJson(json);
    }
  }
}

@JsonSerializable()
class PayFreeModel extends PayBaseModel {
  final int id;
  final int game;
  final int user;

  final ParticipationStatus participation_status;

  PayFreeModel({
    required this.game,
    required this.participation_status,
    required this.user,
    required this.id,
  });

  factory PayFreeModel.fromJson(Map<String, dynamic> json) =>
      _$PayFreeModelFromJson(json);
}
//
// @JsonSerializable()
// class PayReadyModel extends PayBaseModel {
//   final String next_redirect_app_url;
//   final String next_redirect_mobile_url;
//   final String next_redirect_pc_url;
//   final String android_app_scheme;
//   final String ios_app_scheme;
//
//   PayReadyModel({
//     required this.next_redirect_app_url,
//     required this.next_redirect_mobile_url,
//     required this.next_redirect_pc_url,
//     required this.android_app_scheme,
//     required this.ios_app_scheme,
//   });
//
//   factory PayReadyModel.fromJson(Map<String, dynamic> json) =>
//       _$PayReadyModelFromJson(json);
// }

@JsonSerializable()
class PayApprovalModel extends IModelWithId {
  final PayResultModel payment_result;
  final DateTime created_at;
  final ParticipationStatus participation_status;

  PayApprovalModel({
    required this.created_at,
    required this.participation_status,
    required this.payment_result,
    required super.id,
  });

  factory PayApprovalModel.fromJson(Map<String, dynamic> json) =>
      _$PayApprovalModelFromJson(json);
}

@JsonSerializable()
class PayResultModel extends IModelWithId {
  final int quantity;
  final ItemType item_type;
  final int total_amount;
  final int tax_free_amount;
  final int vat_amount;
  final int point_amount;
  final int discount_amount;
  final String status;
  final DateTime created_at;
  final DateTime? approved_at;
  final DateTime? canceled_at;
  final DateTime? failed_at;

  PayResultModel({
    required super.id,
    required this.quantity,
    required this.item_type,
    required this.total_amount,
    required this.created_at,
    required this.approved_at,
    required this.canceled_at,
    required this.failed_at,
    required this.tax_free_amount,
    required this.vat_amount,
    required this.point_amount,
    required this.discount_amount,
    required this.status,
  });

  factory PayResultModel.fromJson(Map<String, dynamic> json) =>
      _$PayResultModelFromJson(json);
}


