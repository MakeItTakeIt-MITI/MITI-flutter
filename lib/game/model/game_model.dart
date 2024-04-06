import 'package:json_annotation/json_annotation.dart';
import 'package:miti/court/model/court_model.dart';

import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';

part 'game_model.g.dart';

@JsonSerializable()
class GameModel extends IModelWithId {
  final GameStatus game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final int fee;
  final CourtModel court;
  final int num_of_participations;
  final int max_invitation;

  GameModel({
    required super.id,
    required this.title,
    required this.game_status,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.fee,
    required this.court,
    required this.num_of_participations,
    required this.max_invitation,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);
}

@JsonSerializable()
class HostModel {
  final String email;
  final String nickname;

  HostModel({
    required this.email,
    required this.nickname,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) =>
      _$HostModelFromJson(json);
}



@JsonSerializable()
class ConfirmedParticipationModel extends IModelWithId {
  final HostModel user;
  final ParticipationStatus participation_status;

  ConfirmedParticipationModel({
    required super.id,
    required this.user,
    required this.participation_status,
  });

  factory ConfirmedParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedParticipationModelFromJson(json);
}

@JsonSerializable()
class GameDetailModel extends IModelWithId {
  final HostModel host;
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
  final List<ConfirmedParticipationModel> confimed_participations;

  final int num_of_confirmed_participations;
  final bool is_participated;
  final bool is_host;

  GameDetailModel({
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
    required this.confimed_participations,
    required this.num_of_confirmed_participations,
    required this.is_participated,
    required this.is_host,
  });

  factory GameDetailModel.fromJson(Map<String, dynamic> json) =>
      _$GameDetailModelFromJson(json);
}
