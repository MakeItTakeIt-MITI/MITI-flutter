import 'package:json_annotation/json_annotation.dart';

part 'participation_settlement_response.g.dart';

@JsonSerializable()
class ParticipationSettlementResponse {
  final String nickname;
  final int fee;

  @JsonKey(name: 'is_settled')
  final bool isSettled;

  ParticipationSettlementResponse({
    required this.nickname,
    required this.fee,
    required this.isSettled,
  });

  factory ParticipationSettlementResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationSettlementResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipationSettlementResponseToJson(this);

  ParticipationSettlementResponse copyWith({
    String? nickname,
    int? fee,
    bool? isSettled,
  }) {
    return ParticipationSettlementResponse(
      nickname: nickname ?? this.nickname,
      fee: fee ?? this.fee,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}
