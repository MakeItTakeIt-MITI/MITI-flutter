import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewBaseModel extends IModelWithId {
  final int rating;
  final String comment;
  final ReviewType review_type;

  ReviewBaseModel({
    required super.id,
    required this.rating,
    required this.comment,
    required this.review_type,
  });

  factory ReviewBaseModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewBaseModelFromJson(json);
}

@JsonSerializable()
class WrittenReviewModel extends ReviewBaseModel {
  final String reviewer_nickname;
  final String reviewee_nickname;

  WrittenReviewModel({
    required super.id,
    required this.reviewee_nickname,
    required super.rating,
    required super.comment,
    required super.review_type,
    required this.reviewer_nickname,
  });

  factory WrittenReviewModel.fromJson(Map<String, dynamic> json) =>
      _$WrittenReviewModelFromJson(json);
}

@JsonSerializable()
class WrittenReviewDetailModel extends IModelWithId {
  final UserReviewModel reviewee;
  final ReviewGameModel game;
  final int rating;
  final String comment;
  final ReviewType review_type;
  final DateTime created_at;
  final int reviewer;

  WrittenReviewDetailModel({
    required super.id,
    required this.reviewee,
    required this.game,
    required this.rating,
    required this.comment,
    required this.review_type,
    required this.created_at,
    required this.reviewer,
  });

  factory WrittenReviewDetailModel.fromJson(Map<String, dynamic> json) =>
      _$WrittenReviewDetailModelFromJson(json);
}

// @JsonSerializable()
// class RevieweeModel extends IModelWithId {
//   final String nickname;
//   final RatingModel rating;
//   final List<WrittenReviewModel> reviews;
//
//   RevieweeModel({
//     required super.id,
//     required this.nickname,
//     required this.rating,
//     required this.reviews,
//   });
//
//   factory RevieweeModel.fromJson(Map<String, dynamic> json) =>
//       _$RevieweeModelFromJson(json);
// }

@JsonSerializable()
class ReceiveReviewModel extends ReviewBaseModel {
  final String game_title;
  final String reviewee;

  ReceiveReviewModel({
    required super.id,
    required this.reviewee,
    required super.rating,
    required super.comment,
    required super.review_type,
    required this.game_title,
  });

  factory ReceiveReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiveReviewModelFromJson(json);
}

@JsonSerializable()
class ReceiveReviewDetailModel extends IModelWithId {
  final ReviewGameModel game;
  final int rating;
  final String comment;
  final String review_type;
  final DateTime created_at;
  final int reviewee;

  ReceiveReviewDetailModel({
    required super.id,
    required this.game,
    required this.rating,
    required this.comment,
    required this.review_type,
    required this.created_at,
    required this.reviewee,
  });

  factory ReceiveReviewDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiveReviewDetailModelFromJson(json);
}
