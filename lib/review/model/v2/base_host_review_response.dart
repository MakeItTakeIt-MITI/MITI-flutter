import 'package:json_annotation/json_annotation.dart';
import '../../../common/model/entity_enum.dart';
import '../../../common/model/model_id.dart';
import '../../../user/model/v2/base_user_response.dart';

part 'base_host_review_response.g.dart';

@JsonSerializable()
class BaseHostReviewResponse extends IModelWithId {
  final int rating;
  final String comment;
  final List<PlayerReviewTagType> tags;
  final BaseUserResponse reviewee;
  final BaseUserResponse reviewer;

  BaseHostReviewResponse({
    required super.id,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.reviewee,
    required this.reviewer,
  });

  factory BaseHostReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseHostReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseHostReviewResponseToJson(this);

  BaseHostReviewResponse copyWith({
    int? id,
    int? rating,
    String? comment,
    List<PlayerReviewTagType>? tags,
    BaseUserResponse? reviewee,
    BaseUserResponse? reviewer,
  }) {
    return BaseHostReviewResponse(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      reviewee: reviewee ?? this.reviewee,
      reviewer: reviewer ?? this.reviewer,
    );
  }
}
