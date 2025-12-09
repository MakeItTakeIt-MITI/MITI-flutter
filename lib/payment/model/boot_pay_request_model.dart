import 'package:json_annotation/json_annotation.dart';
import 'package:miti/payment/model/pay_model.dart';

part 'boot_pay_request_model.g.dart';

@JsonSerializable()
class BootPayRequestModel extends PayBaseModel {
  final int price;
  @JsonKey(name: 'tax_free')
  final int taxFree;
  @JsonKey(name: 'order_name')
  final String orderName;
  @JsonKey(name: 'order_id')
  final String orderId;
  // final PaymentMethodType method;
  final BootPayUserModel user;

  BootPayRequestModel({
    required this.price,
    required this.taxFree,
    required this.orderName,
    required this.orderId,
    // required this.method,
    required this.user,
  });

  factory BootPayRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BootPayRequestModelFromJson(json);
}

@JsonSerializable()
class BootPayUserModel {
  final String username;
  final String phone;

  BootPayUserModel({
    required this.username,
    required this.phone,
  });

  factory BootPayUserModel.fromJson(Map<String, dynamic> json) =>
      _$BootPayUserModelFromJson(json);
}
