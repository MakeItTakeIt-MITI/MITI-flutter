import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';
import 'package:miti/game/model/game_review_model.dart';

import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewListModel {
  final String reviewee_nickname;
  // final Rating guest_rating;
  final List<ReviewHistoryModel> reviews;

  ReviewListModel({
    required this.reviewee_nickname,
    // required this.guest_rating,
    required this.reviews,
  });

  factory ReviewListModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewListModelFromJson(json);
}

@JsonSerializable()
class ReviewHistoryModel extends GameCreateReviewModel {
  final int id;

  const ReviewHistoryModel({
    required this.id,
    required super.reviewee,
    required super.reviewer,
    required super.rating,
    required super.comment,
    required super.tags,
  });

  factory ReviewHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewHistoryModelFromJson(json);
}
