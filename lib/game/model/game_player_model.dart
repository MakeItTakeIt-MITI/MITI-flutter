import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../param/game_param.dart';
import 'game_model.dart';

part 'game_player_model.g.dart';

@JsonSerializable()
class GameRevieweesModel {
  final List<GameParticipationModel> participations;
  final ReviewHostModel? host;

  GameRevieweesModel({
    required this.participations,
    required this.host,
  });

  factory GameRevieweesModel.fromJson(Map<String, dynamic> json) =>
      _$GameRevieweesModelFromJson(json);
}

@JsonSerializable()
class GameParticipationModel extends IModelWithId {
  final String nickname;
  final ParticipationStatus participation_status;
  final Rating guest_rating;
  final List<ReviewerModel> guest_reviews;

  GameParticipationModel({
    required super.id,
    required this.nickname,
    required this.participation_status,
    required this.guest_rating,
    required this.guest_reviews,
  });

  factory GameParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$GameParticipationModelFromJson(json);
}

@JsonSerializable()
class ReviewHostModel {
  final String nickname;
  final Rating host_rating;
  final List<ReviewerModel> host_reviews;

  ReviewHostModel({
    required this.nickname,
    required this.host_rating,
    required this.host_reviews,
  });

  factory ReviewHostModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewHostModelFromJson(json);
}

@JsonSerializable()
class ReviewDetailModel extends GameReviewParam {
  final String reviewer;
  final ReviewGameModel game;

  const ReviewDetailModel({
    required this.reviewer,
    required super.rating,
    required super.comment,
    required super.tags,
    required this.game,
  });

  factory ReviewDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewDetailModelFromJson(json);
}
