import 'package:json_annotation/json_annotation.dart';

import '../base_coupon_info_response.dart';
import 'base_game_meta_response.dart';

part 'participation_payment_detail_response.g.dart';

@JsonSerializable()
class ParticipationPaymentDetailResponse {
  @JsonKey(name: 'game')
  final BaseGameMetaResponse game;

  @JsonKey(name: 'coupon_info')
  final List<BaseCouponInfoResponse> couponInfo;

  /// 비고란에 특정 클래스 명이 없어 Map으로 처리했습니다.
  /// 별도의 모델이 있다면 해당 타입(예: BasePromotionInfoResponse)으로 변경해주세요.
  @JsonKey(name: 'promotion_info')
  final Map<String, dynamic> promotionInfo;

  ParticipationPaymentDetailResponse({
    required this.game,
    required this.couponInfo,
    required this.promotionInfo,
  });

  factory ParticipationPaymentDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationPaymentDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipationPaymentDetailResponseToJson(this);

  ParticipationPaymentDetailResponse copyWith({
    BaseGameMetaResponse? game,
    List<BaseCouponInfoResponse>? couponInfo,
    Map<String, dynamic>? promotionInfo,
  }) {
    return ParticipationPaymentDetailResponse(
      game: game ?? this.game,
      couponInfo: couponInfo ?? this.couponInfo,
      promotionInfo: promotionInfo ?? this.promotionInfo,
    );
  }
}
