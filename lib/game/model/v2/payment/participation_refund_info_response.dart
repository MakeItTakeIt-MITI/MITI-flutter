import 'package:json_annotation/json_annotation.dart';
import '../game/game_with_court_response.dart';
import 'payment_refund_amount.dart'; // PaymentRefundAmount 클래스 import

part 'participation_refund_info_response.g.dart';

@JsonSerializable()
class ParticipationRefundInfoResponse {
  @JsonKey(name: 'quantity')
  final int quantity;

  @JsonKey(name: 'item_type')
  final String itemType;

  @JsonKey(name: 'participation_id')
  final int participationId;

  final GameWithCourtResponse game;

  @JsonKey(name: 'refund_info')
  final PaymentRefundAmount refundInfo;

  ParticipationRefundInfoResponse({
    required this.quantity,
    required this.itemType,
    required this.participationId,
    required this.game,
    required this.refundInfo,
  });

  factory ParticipationRefundInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationRefundInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipationRefundInfoResponseToJson(this);

  ParticipationRefundInfoResponse copyWith({
    int? quantity,
    String? itemType,
    int? participationId,
    GameWithCourtResponse? game,
    PaymentRefundAmount? refundInfo,
  }) {
    return ParticipationRefundInfoResponse(
      quantity: quantity ?? this.quantity,
      itemType: itemType ?? this.itemType,
      participationId: participationId ?? this.participationId,
      game: game ?? this.game,
      refundInfo: refundInfo ?? this.refundInfo,
    );
  }
}
