import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'boot_pay_approve_param.g.dart';

@JsonSerializable()
class BootPayApproveParam extends Equatable {
  final String event;
  @JsonKey(name: 'receipt_id')
  final String receiptId;
  @JsonKey(name: 'gateway_url')
  final String gatewayUrl;
  @JsonKey(name: 'order_id')
  final String orderId;

  const BootPayApproveParam({
    required this.event,
    required this.receiptId,
    required this.gatewayUrl,
    required this.orderId,
  });

  @override
  List<Object?> get props => [event, receiptId, gatewayUrl, orderId];

  @override
  bool? get stringify => true;

  Map<String, dynamic> toJson() => _$BootPayApproveParamToJson(this);

  factory BootPayApproveParam.fromJson(Map<String, dynamic> json) =>
      _$BootPayApproveParamFromJson(json);
}
