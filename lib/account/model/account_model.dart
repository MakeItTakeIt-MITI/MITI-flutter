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
  @JsonKey(name: 'settlement_amount')
  final int settlementAmount;
  final SettlementStatusType status;
  final ReviewGameModel game;

  SettlementModel({
    required super.id,
    required this.amount,
    required this.commission,
    required this.settlementAmount,
    required this.status,
    required this.game,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) =>
      _$SettlementModelFromJson(json);
}

/*
        "id": 21,
        "status": "completed",
        "amount": 10000,
        "commission": 250,
        "settlement_amount": 9750,
        "expected_settlement_amount": 9750,
        "game": {
            "id": 25692,
            "game_status": "completed",
            "title": "KHU MITI 픽업게임",
            "startdate": "2024-09-04",
            "starttime": "20:00:00",
            "enddate": "2024-09-04",
            "endtime": "20:10:00",
            "max_invitation": 12,
            "min_invitation": 1,
            "fee": 10000,
            "court": {
                "id": 24,
                "address": "서울 동대문구 경희대로 1 (회기동)",
                "address_detail": "miti at ku",
                "latitude": "37.5917474794325",
                "longitude": "127.052102908464"
            }
        },
        "participations": [
            {
                "nickname": "testuser4",
                "fee": 10000,
                "is_settled": true
            }
        ]

 */
/*
  id
  status_code
  amount
  commission
  settlement_amount
  expected_settlement_amount
  game
  id
  game_status
  title
  startdate
  starttime
  enddate
  endtime
  max_invitation
  min_invitation
  fee
  court
  id
  address
  address_detail
  latitude
  longitude
  participations
  nickname
  fee
  is_settled

 */
@JsonSerializable()
class SettlementDetailModel extends IModelWithId {
  final SettlementStatusType status;
  final int amount;
  final int commission;
  @JsonKey(name: 'settlement_amount')
  final int settlementAmount;
  @JsonKey(name: 'expected_settlement_amount')
  final int expectedSettlementAmount;
  final ReviewGameModel game;
  final List<ParticipationModel> participations;

  SettlementDetailModel({
    required super.id,
    required this.status,
    required this.amount,
    required this.commission,
    required this.settlementAmount,
    required this.expectedSettlementAmount,
    required this.game,
    required this.participations,
  });

  factory SettlementDetailModel.fromJson(Map<String, dynamic> json) =>
      _$SettlementDetailModelFromJson(json);
}

@JsonSerializable()
class ParticipationModel {
  final String nickname;
  final int fee;
  final bool is_settled;

  ParticipationModel({
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

  final GameStatusType game_status;
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
  @JsonKey(name: "account_type")
  final AccountType accountType;
  final AccountStatus status;

  AccountModel({
    required super.id,
    required this.balance,
    required this.accountType,
    required this.status,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);
}

@JsonSerializable()
class AccountDetailModel extends AccountModel {
  @JsonKey(name: "transfer_requested_amount")
  final int transferRequestedAmount;
  @JsonKey(name: "requestable_transfer_amount")
  final int requestableTransferAmount;

  AccountDetailModel({
    required super.id,
    required super.balance,
    required super.accountType,
    required super.status,
    required this.transferRequestedAmount,
    required this.requestableTransferAmount,
  });

  factory AccountDetailModel.fromJson(Map<String, dynamic> json) =>
      _$AccountDetailModelFromJson(json);
}
