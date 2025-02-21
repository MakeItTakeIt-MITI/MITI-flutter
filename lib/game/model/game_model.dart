import 'package:bootpay/user_info.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:miti/user/model/review_model.dart';

import '../../auth/model/code_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../user/model/user_model.dart';

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
  final List<GameHostModel> games;

  GameListByDateModel({
    required this.startdate,
    required this.games,
  });

  factory GameListByDateModel.fromJson(Map<String, dynamic> json) =>
      _$GameListByDateModelFromJson(json);
}

@JsonSerializable()
class GameHostModel extends IModelWithId {
  final GameStatusType game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final int fee;
  final int num_of_participations;
  final int min_invitation;
  final int max_invitation;

  GameHostModel({
    required super.id,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.fee,
    required this.num_of_participations,
    required this.min_invitation,
    required this.max_invitation,
  });

  factory GameHostModel.fromJson(Map<String, dynamic> json) =>
      _$GameHostModelFromJson(json);
}

@JsonSerializable()
class GameBaseModel extends IModelWithId {
  final GameStatusType game_status;
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
class UserReviewModel extends NullIModelWithId {
  @JsonKey(name: 'profile_image_url')
  final String profileImageUrl;
  final String nickname;
  final RatingModel rating;

  UserReviewModel({
    required this.profileImageUrl,
    required this.nickname,
    required this.rating,
    super.id,
  });

  factory UserReviewModel.fromJson(Map<String, dynamic> json) =>
      _$UserReviewModelFromJson(json);
}

@JsonSerializable()
class ReviewerModel extends IModelWithId {
  final int reviewer;

  ReviewerModel({
    required this.reviewer,
    required super.id,
  });

  factory ReviewerModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewerModelFromJson(json);
}

@JsonSerializable()
class RatingModel {
  final Rating host_rating;
  final Rating guest_rating;

  RatingModel({
    required this.host_rating,
    required this.guest_rating,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);
}

@JsonSerializable()
class Rating {
  final int num_of_reviews;
  final double? average_rating;

  Rating({
    required this.num_of_reviews,
    required this.average_rating,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
}

@JsonSerializable()
class ConfirmedParticipationModel extends NullIModelWithId {
  final ParticipationStatusType participation_status;
  final UserInfoModel user;

  ConfirmedParticipationModel({
    super.id,
    required this.participation_status,
    required this.user,
  });

  factory ConfirmedParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedParticipationModelFromJson(json);
}

@JsonSerializable()
class ParticipationModel extends IModelWithId {
  final UserInfoModel user;
  final ParticipationStatusType participation_status;

  ParticipationModel({
    required super.id,
    required this.user,
    required this.participation_status,
  });

  factory ParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipationModelFromJson(json);
}

@JsonSerializable()
class GameDetailModel extends IModelWithId {
  final UserReviewModel host;
  final CourtGameModel court;

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
  final int? user_participation_id;
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
    required this.user_participation_id,
    required this.is_host,
    required this.participation,
  });

  factory GameDetailModel.fromJson(Map<String, dynamic> json) =>
      _$GameDetailModelFromJson(json);
}
