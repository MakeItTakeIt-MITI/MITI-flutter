import 'package:json_annotation/json_annotation.dart';
import '../../../common/model/entity_enum.dart';
import '../../../common/model/model_id.dart';
import '../../../user/model/v2/base_user_response.dart';

part 'base_guest_review_response.g.dart';

@JsonSerializable()
class BaseGuestReviewResponse extends IModelWithId {
  final int rating;
  final String comment;
  final List<PlayerReviewTagType> tags;
  final BaseUserResponse reviewee;
  final BaseUserResponse reviewer;

  BaseGuestReviewResponse({
    required super.id,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.reviewee,
    required this.reviewer,
  });

  factory BaseGuestReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGuestReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGuestReviewResponseToJson(this);

  BaseGuestReviewResponse copyWith({
    int? id,
    int? rating,
    String? comment,
    List<PlayerReviewTagType>? tags,
    BaseUserResponse? reviewee,
    BaseUserResponse? reviewer,
  }) {
    return BaseGuestReviewResponse(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      reviewee: reviewee ?? this.reviewee,
      reviewer: reviewer ?? this.reviewer,
    );
  }
}
