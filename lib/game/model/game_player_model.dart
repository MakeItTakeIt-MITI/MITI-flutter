import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';
import 'package:miti/user/model/user_model.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../param/game_param.dart';
import 'game_model.dart';

part 'game_player_model.g.dart';

@JsonSerializable()
class GameRevieweesModel {
  final ReviewHostModel? host;
  final List<GameParticipationModel> participations;
  @JsonKey(name: 'user_written_reviews')
  final UserWrittenReviewsModel userWrittenReviews;

  GameRevieweesModel({
    required this.host,
    required this.participations,
    required this.userWrittenReviews,
  });

  factory GameRevieweesModel.fromJson(Map<String, dynamic> json) =>
      _$GameRevieweesModelFromJson(json);
}

@JsonSerializable()
class UserWrittenReviewsModel {
  @JsonKey(name: 'written_host_review_id')
  final int? writtenHostReviewId;
  @JsonKey(name: 'written_participation_ids')
  final List<int> writtenParticipationIds;

  UserWrittenReviewsModel({
    required this.writtenHostReviewId,
    required this.writtenParticipationIds,
  });

  factory UserWrittenReviewsModel.fromJson(Map<String, dynamic> json) =>
      _$UserWrittenReviewsModelFromJson(json);
}

@JsonSerializable()
class GameParticipationModel extends IModelWithId {
  @JsonKey(name: 'participation_status')
  final ParticipationStatus participationStatus;
  @JsonKey(name: 'guest_rating')
  final Rating guestRating;
  final UserInfoModel user;

  GameParticipationModel({
    required super.id,
    required this.participationStatus,
    required this.guestRating,
    required this.user,
  });

  factory GameParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$GameParticipationModelFromJson(json);
}

@JsonSerializable()
class GameParticipationPlayerModel extends IModelWithId {
  final ParticipationStatus participation_status;
  final PlayerModel user;

  GameParticipationPlayerModel({
    required super.id,
    required this.participation_status,
    required this.user,
  });

  factory GameParticipationPlayerModel.fromJson(Map<String, dynamic> json) =>
      _$GameParticipationPlayerModelFromJson(json);
}

@JsonSerializable()
class PlayerModel extends NullIModelWithId {
  final String nickname;
  @JsonKey(name: 'profile_image_url')
  final String profileImageUrl;
  @JsonKey(name: 'guest_rating')
  final Rating guestRating;
  @JsonKey(name: 'player_profile')
  final UserPlayerModel playerProfile;

  PlayerModel({
    super.id,
    required this.profileImageUrl,
    required this.nickname,
    required this.guestRating,
    required this.playerProfile,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);
}

@JsonSerializable()
class ReviewHostModel extends IModelWithId{
  final String nickname;
  @JsonKey(name: 'profile_image_url')
  final String profileImageUrl;
  @JsonKey(name: 'host_rating')
  final Rating hostRating;

  ReviewHostModel({
    required super.id,
    required this.profileImageUrl,
    required this.nickname,
    required this.hostRating,
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
