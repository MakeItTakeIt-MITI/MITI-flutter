import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import 'game_model.dart';

part 'game_player_model.g.dart';

@JsonSerializable()
class GamePlayerListModel {
  final List<GameParticipationModel> participations;
  final GamePlayerModel? host;

  GamePlayerListModel({
    required this.participations,
    required this.host,
  });

  factory GamePlayerListModel.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerListModelFromJson(json);
}

@JsonSerializable()
class GameParticipationModel extends IModelWithId {
  final ParticipationStatus participation_status;
  final GamePlayerModel user;

  GameParticipationModel({
    required super.id,
    required this.participation_status,
    required this.user,
  });

  factory GameParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$GameParticipationModelFromJson(json);
}

@JsonSerializable()
class GamePlayerModel extends IModelWithId {
  final String nickname;
  final RatingModel rating;

  GamePlayerModel({
    required super.id,
    required this.nickname,
    required this.rating,
  });

  factory GamePlayerModel.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerModelFromJson(json);
}
