import 'package:json_annotation/json_annotation.dart';

part 'participation_payment_refund_info_response.g.dart';

@JsonSerializable()
class ParticipationPaymentRefundInfoResponse {
  /// 원 상품 가격
  @JsonKey(name: 'origin_amount')
  final int originAmount;

  /// 할인 금액
  @JsonKey(name: 'discount_amount')
  final int discountAmount;

  /// 최종 결제 금액
  @JsonKey(name: 'final_amount')
  final int finalAmount;

  /// 환불 수수료 금액
  @JsonKey(name: 'refund_commission_amount')
  final int refundCommissionAmount;

  /// 최종 환불 금액
  @JsonKey(name: 'final_refund_amount')
  final int finalRefundAmount;

  ParticipationPaymentRefundInfoResponse({
    required this.originAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.refundCommissionAmount,
    required this.finalRefundAmount,
  });

  factory ParticipationPaymentRefundInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationPaymentRefundInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipationPaymentRefundInfoResponseToJson(this);

  // 선택 사항: copyWith 메서드 추가
  ParticipationPaymentRefundInfoResponse copyWith({
    int? originAmount,
    int? discountAmount,
    int? finalAmount,
    int? refundCommissionAmount,
    int? finalRefundAmount,
  }) {
    return ParticipationPaymentRefundInfoResponse(
      originAmount: originAmount ?? this.originAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      refundCommissionAmount: refundCommissionAmount ?? this.refundCommissionAmount,
      finalRefundAmount: finalRefundAmount ?? this.finalRefundAmount,
    );
  }
}
