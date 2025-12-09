

import 'package:json_annotation/json_annotation.dart';

part 'payment_extra.g.dart';

@JsonSerializable()
class PaymentExtra {
  @JsonKey(name: 'common_event_webhook')
  final bool commonEventWebhook;
  @JsonKey(name: 'enable_error_webhook')
  final bool enableErrorWebhook;

  PaymentExtra({
    required this.commonEventWebhook,
    required this.enableErrorWebhook,
  });

  factory PaymentExtra.fromJson(Map<String, dynamic> json) =>
      _$PaymentExtraFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentExtraToJson(this);

  PaymentExtra copyWith({
    bool? commonEventWebhook,
    bool? enableErrorWebhook,
  }) {

    return PaymentExtra(
      commonEventWebhook: commonEventWebhook ?? this.commonEventWebhook,
      enableErrorWebhook: enableErrorWebhook ?? this.enableErrorWebhook,
    );
  }
}
