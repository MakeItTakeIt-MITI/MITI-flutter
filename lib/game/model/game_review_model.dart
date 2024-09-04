import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';
import 'package:miti/game/model/game_model.dart';

import '../../common/model/entity_enum.dart';
import '../param/game_param.dart';

part 'game_review_model.g.dart';

@JsonSerializable()
class GameCreateReviewModel extends GameReviewParam {
  final UserInfoModel reviewee;
  final UserInfoModel reviewer;

  const GameCreateReviewModel({
    required this.reviewee,
    required this.reviewer,
    required super.rating,
    required super.comment,
    required super.tags,
  });

  factory GameCreateReviewModel.fromJson(Map<String, dynamic> json) =>
      _$GameCreateReviewModelFromJson(json);
}
