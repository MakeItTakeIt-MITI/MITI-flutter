import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:miti/user/model/review_model.dart';

import '../../auth/model/code_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';

part 'game_model.g.dart';

class MapPosition extends Equatable {
  final double latitude;
  final double longitude;

  const MapPosition({
    required this.longitude,
    required this.latitude,
  });

  @override
  List<Object?> get props => [longitude, latitude];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class GameListByDateModel extends Base {
  final String startdate;
  final List<GameBaseModel> games;

  GameListByDateModel({
    required this.startdate,
    required this.games,
  });

  factory GameListByDateModel.fromJson(Map<String, dynamic> json) =>
      _$GameListByDateModelFromJson(json);
}

@JsonSerializable()
class GameBaseModel extends IModelWithId {
  final GameStatus game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final CourtModel court;

  GameBaseModel({
    required super.id,
    required this.title,
    required this.game_status,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.court,
  });

  factory GameBaseModel.fromJson(Map<String, dynamic> json) =>
      _$GameBaseModelFromJson(json);
}

@JsonSerializable()
class GameModel extends GameBaseModel {
  final int num_of_participations;
  final int fee;
  final int max_invitation;

  GameModel({
    required super.id,
    required super.title,
    required super.game_status,
    required super.startdate,
    required super.starttime,
    required super.enddate,
    required super.endtime,
    required this.fee,
    required super.court,
    required this.num_of_participations,
    required this.max_invitation,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);
}

@JsonSerializable()
class ReviewGameModel extends GameBaseModel {
  final int min_invitation;
  final int fee;
  final int max_invitation;

  ReviewGameModel({
    required super.id,
    required super.court,
    required super.game_status,
    required super.title,
    required super.startdate,
    required super.starttime,
    required super.enddate,
    required super.endtime,
    required this.min_invitation,
    required this.max_invitation,
    required this.fee,
  });

  factory ReviewGameModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewGameModelFromJson(json);
}

@JsonSerializable()
class UserReviewModel extends IModelWithId {
  final String nickname;
  final RatingModel rating;
  final List<WrittenReviewModel> reviews;

  UserReviewModel({
    required this.nickname,
    required this.rating,
    required this.reviews,
    required super.id,
  });

  factory UserReviewModel.fromJson(Map<String, dynamic> json) =>
      _$UserReviewModelFromJson(json);
}

@JsonSerializable()
class RatingModel extends IModelWithId {
  final int num_of_reviews;
  final double average_rating;

  RatingModel({
    required super.id,
    required this.num_of_reviews,
    required this.average_rating,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);
}

@JsonSerializable()
class ConfirmedParticipationModel extends IModelWithId {
  final String nickname;
  final ParticipationStatus participation_status;

  ConfirmedParticipationModel({
    required super.id,
    required this.nickname,
    required this.participation_status,
  });

  factory ConfirmedParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedParticipationModelFromJson(json);
}

@JsonSerializable()
class ParticipationModel extends IModelWithId {
  final UserInfoModel user;
  final ParticipationStatus participation_status;

  ParticipationModel({
    required super.id,
    required this.user,
    required this.participation_status,
  });

  factory ParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipationModelFromJson(json);
}

@JsonSerializable()
class UserInfoModel {
  final String email;
  final String nickname;

  UserInfoModel({
    required this.email,
    required this.nickname,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
}

@JsonSerializable()
class GameDetailModel extends IModelWithId {
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
  final bool is_participated;
  final bool is_host;
  final ParticipationModel? participation;

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
    required this.confirmed_participations,
    required this.num_of_confirmed_participations,
    required this.is_participated,
    required this.is_host,
    required this.participation,
  });

  factory GameDetailModel.fromJson(Map<String, dynamic> json) =>
      _$GameDetailModelFromJson(json);
}
