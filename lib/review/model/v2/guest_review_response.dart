import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../../common/model/model_id.dart';
import '../../../game/model/v2/game/game_with_court_response.dart';
import '../../../user/model/v2/base_user_response.dart';
import 'host_review_response.dart';

part 'guest_review_response.g.dart';

@JsonSerializable()
class GuestReviewResponse extends BaseReviewResponse {
  GuestReviewResponse({
    required super.id,
    required super.rating,
    required super.comment,
    required super.tags,
    required super.reviewee,
    required super.reviewer,
    required super.game,
  });

  factory GuestReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$GuestReviewResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GuestReviewResponseToJson(this);

  @override
  GuestReviewResponse copyWith({
    int? id,
    int? rating,
    String? comment,
    List<PlayerReviewTagType>? tags,
    BaseUserResponse? reviewee,
    BaseUserResponse? reviewer,
    GameWithCourtResponse? game,
  }) {
    return GuestReviewResponse(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      reviewee: reviewee ?? this.reviewee,
      reviewer: reviewer ?? this.reviewer,
      game: game ?? this.game,
    );
  }
}
