import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_game_settlement_response.g.dart';

@JsonSerializable()
class BaseGameSettlementResponse extends IModelWithId{

  final SettlementStatusType status;

  @JsonKey(name: 'settlement_type')
  final SettlementType settlementType;

  @JsonKey(name: 'settlement_amount')
  final int settlementAmount;

  @JsonKey(name: 'commission_amount')
  final int commissionAmount;

  @JsonKey(name: 'final_settlement_amount')
  final int finalSettlementAmount;

  BaseGameSettlementResponse({
    required super.id,
    required this.status,
    required this.settlementType,
    required this.settlementAmount,
    required this.commissionAmount,
    required this.finalSettlementAmount,
  });

  factory BaseGameSettlementResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameSettlementResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameSettlementResponseToJson(this);

  BaseGameSettlementResponse copyWith({
    int? id,
    SettlementStatusType? status,
    SettlementType? settlementType,
    int? settlementAmount,
    int? commissionAmount,
    int? finalSettlementAmount,
  }) {
    return BaseGameSettlementResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      settlementType: settlementType ?? this.settlementType,
      settlementAmount: settlementAmount ?? this.settlementAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      finalSettlementAmount: finalSettlementAmount ?? this.finalSettlementAmount,
    );
  }
}
