import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';
import '../game/base_game_with_court_response.dart';
import '../participation/participation_settlement_response.dart';
import 'expected_settlement_amount.dart'; // ExpectedSettlementAmount 클래스 import

part 'game_settlement_detail_response.g.dart';

@JsonSerializable()
class GameSettlementDetailResponse extends IModelWithId {
  @JsonKey(name: 'status')
  final SettlementStatusType status;

  @JsonKey(name: 'settlement_type')
  final SettlementType settlementType;

  @JsonKey(name: 'settlement_amount')
  final int settlementAmount;

  @JsonKey(name: 'commission_amount')
  final int commissionAmount;

  @JsonKey(name: 'final_settlement_amount')
  final int finalSettlementAmount;

  final BaseGameWithCourtResponse game;

  @JsonKey(name: 'expected_settlement_amount')
  final ExpectedSettlementAmount expectedSettlementAmount;

  @JsonKey(name: 'participations')
  final List<ParticipationSettlementResponse> participations;

  GameSettlementDetailResponse({
    required super.id,
    required this.status,
    required this.settlementType,
    required this.settlementAmount,
    required this.commissionAmount,
    required this.finalSettlementAmount,
    required this.game,
    required this.expectedSettlementAmount,
    required this.participations,
  });

  factory GameSettlementDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$GameSettlementDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GameSettlementDetailResponseToJson(this);

  GameSettlementDetailResponse copyWith({
    int? id,
    SettlementStatusType? status,
    SettlementType? settlementType,
    int? settlementAmount,
    int? commissionAmount,
    int? finalSettlementAmount,
    BaseGameWithCourtResponse? game,
    ExpectedSettlementAmount? expectedSettlementAmount,
    List<ParticipationSettlementResponse>? participations,
  }) {
    return GameSettlementDetailResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      settlementType: settlementType ?? this.settlementType,
      settlementAmount: settlementAmount ?? this.settlementAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      finalSettlementAmount:
          finalSettlementAmount ?? this.finalSettlementAmount,
      game: game ?? this.game,
      expectedSettlementAmount:
          expectedSettlementAmount ?? this.expectedSettlementAmount,
      participations: participations ?? this.participations,
    );
  }
}
