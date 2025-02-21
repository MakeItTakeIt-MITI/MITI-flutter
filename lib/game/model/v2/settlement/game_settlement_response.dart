import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../game/base_game_with_court_response.dart';

part 'game_settlement_response.g.dart';

@JsonSerializable()
class GameSettlementResponse extends IModelWithId{

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

  GameSettlementResponse({
    required super.id,
    required this.status,
    required this.settlementType,
    required this.settlementAmount,
    required this.commissionAmount,
    required this.finalSettlementAmount,
    required this.game,
  });

  factory GameSettlementResponse.fromJson(Map<String, dynamic> json) =>
      _$GameSettlementResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GameSettlementResponseToJson(this);

  GameSettlementResponse copyWith({
    int? id,
    SettlementStatusType? status,
    SettlementType? settlementType,
    int? settlementAmount,
    int? commissionAmount,
    int? finalSettlementAmount,
    BaseGameWithCourtResponse? game,
  }) {
    return GameSettlementResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      settlementType: settlementType ?? this.settlementType,
      settlementAmount: settlementAmount ?? this.settlementAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      finalSettlementAmount:
          finalSettlementAmount ?? this.finalSettlementAmount,
      game: game ?? this.game,
    );
  }
}
