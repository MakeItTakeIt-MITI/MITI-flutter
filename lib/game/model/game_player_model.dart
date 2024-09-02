import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import 'game_model.dart';

part 'game_player_model.g.dart';

@JsonSerializable()
class GameRevieweesModel {
  final List<GameParticipationModel> participations;
  final GamePlayerModel? host;

  GameRevieweesModel({
    required this.participations,
    required this.host,
  });

  factory GameRevieweesModel.fromJson(Map<String, dynamic> json) =>
      _$GameRevieweesModelFromJson(json);
}

@JsonSerializable()
class GameParticipationModel extends IModelWithId {
  final int user;
  final ParticipationStatus participation_status;
  final Rating guest_rating;
  final List<ReviewerModel> guest_reviews;


  GameParticipationModel({
    required super.id,
    required this.user,
    required this.participation_status,
    required this.guest_rating,
    required this.guest_reviews,
  });

  factory GameParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$GameParticipationModelFromJson(json);
}

@JsonSerializable()
class GamePlayerModel  {
  final Rating host_rating;
  final List<ReviewerModel> host_reviews;


  GamePlayerModel({
    required this.host_rating,
    required this.host_reviews,
  });

  factory GamePlayerModel.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerModelFromJson(json);
}
