import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../../game/param/game_param.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewBaseModel extends GameReviewParam implements Base {
  final int id;
  final ReviewType review_type;

  const ReviewBaseModel({
    required this.id,
    required super.rating,
    required super.comment,
    required super.tags,
    required this.review_type,
  });

  factory ReviewBaseModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewBaseModelFromJson(json);
}

@JsonSerializable()
class WrittenReviewModel extends ReviewBaseModel {
  final String reviewee;

  const WrittenReviewModel({
    required super.id,
    required this.reviewee,
    required super.rating,
    required super.comment,
    required super.review_type,
    required super.tags,
  });

  factory WrittenReviewModel.fromJson(Map<String, dynamic> json) =>
      _$WrittenReviewModelFromJson(json);
}

@JsonSerializable()
class MyReviewDetailBaseModel extends GameReviewParam {
  final int id;
  final ReviewGameModel game;

  const MyReviewDetailBaseModel({
    required this.id,
    required super.rating,
    required super.comment,
    required super.tags,
    required this.game,
  });

  factory MyReviewDetailBaseModel.fromJson(Map<String, dynamic> json) =>
      _$MyReviewDetailBaseModelFromJson(json);
}

@JsonSerializable()
class MyWrittenReviewDetailModel extends MyReviewDetailBaseModel {
  final String reviewee;

  const MyWrittenReviewDetailModel({
    required super.id,
    required this.reviewee,
    required super.rating,
    required super.comment,
    required super.tags,
    required super.game,
  });

  factory MyWrittenReviewDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MyWrittenReviewDetailModelFromJson(json);
}

@JsonSerializable()
class MyReceiveReviewDetailModel extends MyReviewDetailBaseModel {
  final String reviewer;

  const MyReceiveReviewDetailModel({
    required super.id,
    required this.reviewer,
    required super.rating,
    required super.comment,
    required super.tags,
    required super.game,
  });

  factory MyReceiveReviewDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MyReceiveReviewDetailModelFromJson(json);
}

@JsonSerializable()
class ReceiveReviewModel extends ReviewBaseModel {
  final String reviewer;
  final GameReviewBaseModel game;

  const ReceiveReviewModel({
    required super.id,
    required this.reviewer,
    required super.rating,
    required super.comment,
    required super.review_type,
    required super.tags,
    required this.game,
  });

  factory ReceiveReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiveReviewModelFromJson(json);
}

@JsonSerializable()
class GameReviewBaseModel extends IModelWithId {
  final GameStatus game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;

  GameReviewBaseModel({
    required super.id,
    required this.title,
    required this.game_status,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
  });

  factory GameReviewBaseModel.fromJson(Map<String, dynamic> json) =>
      _$GameReviewBaseModelFromJson(json);
}
