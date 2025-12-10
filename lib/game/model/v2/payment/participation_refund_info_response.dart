import 'package:json_annotation/json_annotation.dart';

import '../../../../payment/model/base_coupon_usage_response.dart';
import '../../../../payment/model/participation_payment_refund_info_response.dart';
import '../../base_game_with_court_response.dart';

part 'participation_refund_info_response.g.dart';

@JsonSerializable()
class ParticipationRefundInfoResponse {
  /// 참여 경기 정보
  @JsonKey(name: 'game')
  final BaseGameWithCourtResponse gameInfo;

  /// 적용 쿠폰 정보
  @JsonKey(name: 'coupon_info')
  final BaseCouponUsageResponse couponInfo;

  /// 적용 프로모션 할인 정보
  @JsonKey(name: 'promotion_info')
  final Map<String, dynamic> promotionInfo;

  /// 환불 정보
  @JsonKey(name: 'refund_info')
  final ParticipationPaymentRefundInfoResponse refundInfo;

  ParticipationRefundInfoResponse({
    required this.gameInfo,
    required this.couponInfo,
    required this.promotionInfo,
    required this.refundInfo,
  });

  factory ParticipationRefundInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationRefundInfoResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ParticipationRefundInfoResponseToJson(this);

  // 선택 사항: copyWith 메서드 추가
  ParticipationRefundInfoResponse copyWith({
    BaseGameWithCourtResponse? gameInfo,
    BaseCouponUsageResponse? couponInfo,
    Map<String, dynamic>? promotionInfo,
    ParticipationPaymentRefundInfoResponse? refundInfo,
  }) {
    return ParticipationRefundInfoResponse(
      gameInfo: gameInfo ?? this.gameInfo,
      couponInfo: couponInfo ?? this.couponInfo,
      promotionInfo: promotionInfo ?? this.promotionInfo,
      refundInfo: refundInfo ?? this.refundInfo,
    );
  }
}
