import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../game/model/v2/game/base_game_response.dart';
import '../../../user/model/v2/base_user_response.dart';

part 'base_received_review_response.g.dart';

@JsonSerializable()
class BaseReceivedReviewResponse extends IModelWithId {
  @JsonKey(name: 'review_id')
  final int reviewId;
  @JsonKey(name: 'review_type')
  final ReviewType reviewType;
  final int rating;
  final String comment;
  final List<PlayerReviewTagType> tags;
  final BaseUserResponse reviewer;
  final BaseGameResponse game;

  BaseReceivedReviewResponse({
    required super.id,
    required this.reviewId,
    required this.reviewType,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.reviewer,
    required this.game,
  });

  factory BaseReceivedReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseReceivedReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseReceivedReviewResponseToJson(this);

  BaseReceivedReviewResponse copyWith({
    int? id,
    int? reviewId,
    ReviewType? reviewType,
    int? rating,
    String? comment,
    List<PlayerReviewTagType>? tags,
    BaseUserResponse? reviewer,
    BaseGameResponse? game,
  }) {
    return BaseReceivedReviewResponse(
      id: id ?? this.id,
      reviewId: reviewId ?? this.reviewId,
      reviewType: reviewType ?? this.reviewType,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? List.from(this.tags),
      // 리스트는 새로운 인스턴스로 복사
      reviewer: reviewer ?? this.reviewer,
      game: game ?? this.game,
    );
  }
}
