import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../common/model/entity_enum.dart';
part 'game_review_model.g.dart';

@JsonSerializable()
class GameCreateReviewModel extends IModelWithId {
  final int reviewee;
  final int reviewer;
  final ReviewType review_type;

  GameCreateReviewModel({
    required super.id,
  required this.reviewee,
  required this.reviewer,
  required this.review_type,
  });

  factory GameCreateReviewModel.fromJson(Map<String, dynamic> json) =>
      _$GameCreateReviewModelFromJson(json);
}
