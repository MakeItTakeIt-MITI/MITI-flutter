import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../../court/model/court_model.dart';
import '../../game/model/game_model.dart';

part 'account_model.g.dart';

@JsonSerializable()
class SettlementModel extends IModelWithId {
  final int amount;
  final int commission;
  final SettlementType status;
  final ReviewGameModel game;

  SettlementModel({
    required super.id,
    required this.amount,
    required this.commission,
    required this.status,
    required this.game,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) =>
      _$SettlementModelFromJson(json);
}

@JsonSerializable()
class SettlementDetailModel extends IModelWithId {
  final int amount;
  final int commission;
  final SettlementType status;
  final GameSettlementModel game;
  final int final_settlement_amount;
  final List<ParticipationModel> participations;

  SettlementDetailModel({
    required super.id,
    required this.amount,
    required this.status,
    required this.game,
    required this.participations,
    required this.commission,
    required this.final_settlement_amount,
  });

  factory SettlementDetailModel.fromJson(Map<String, dynamic> json) =>
      _$SettlementDetailModelFromJson(json);
}

@JsonSerializable()
class ParticipationModel extends IModelWithId {
  final int nickname;
  final int fee;
  final bool is_settled;

  ParticipationModel({
    required super.id,
    required this.nickname,
    required this.fee,
    required this.is_settled,
  });

  factory ParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipationModelFromJson(json);
}

@JsonSerializable()
class GameSettlementModel extends IModelWithId {
  final UserReviewModel host;
  final CourtDetailModel court;

  final GameStatus game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final int min_invitation;
  final int max_invitation;
  final String info;
  final int fee;
  final DateTime created_at;
  final DateTime modified_at;
  final List<ConfirmedParticipationModel> confirmed_participations;
  final int num_of_confirmed_participations;

  GameSettlementModel({
    required super.id,
    required this.host,
    required this.court,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.min_invitation,
    required this.max_invitation,
    required this.info,
    required this.fee,
    required this.created_at,
    required this.modified_at,
    required this.confirmed_participations,
    required this.num_of_confirmed_participations,
  });

  factory GameSettlementModel.fromJson(Map<String, dynamic> json) =>
      _$GameSettlementModelFromJson(json);
}

@JsonSerializable()
class AccountModel extends IModelWithId {
  final int balance;
  final int point;
  final AccountType account_type;
  final AccountStatus status;

  AccountModel({
    required super.id,
    required this.balance,
    required this.point,
    required this.account_type,
    required this.status,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);
}

@JsonSerializable()
class AccountDetailModel extends AccountModel {
  final int accumulated_requested_amount;
  final int requestable_transfer_amount;

  AccountDetailModel({
    required super.id,
    required super.balance,
    required super.point,
    required super.account_type,
    required super.status,
    required this.accumulated_requested_amount,
    required this.requestable_transfer_amount,
  });

  factory AccountDetailModel.fromJson(Map<String, dynamic> json) =>
      _$AccountDetailModelFromJson(json);
}
