import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../../common/model/model_id.dart';
import '../../../game/model/v2/game/game_with_court_response.dart';
import '../../../user/model/v2/base_user_response.dart';

part 'host_review_response.g.dart';

@JsonSerializable()
class HostReviewResponse extends IModelWithId {
  final int rating;
  final String comment;
  final List<PlayerReviewTagType> tags;
  final BaseUserResponse reviewee;
  final BaseUserResponse reviewer;
  final GameWithCourtResponse game;

  HostReviewResponse({
    required super.id,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.reviewee,
    required this.reviewer,
    required this.game,
  });

  factory HostReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$HostReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HostReviewResponseToJson(this);

  HostReviewResponse copyWith({
    int? id,
    int? rating,
    String? comment,
    List<PlayerReviewTagType>? tags,
    BaseUserResponse? reviewee,
    BaseUserResponse? reviewer,
    GameWithCourtResponse? game,
  }) {
    return HostReviewResponse(
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
