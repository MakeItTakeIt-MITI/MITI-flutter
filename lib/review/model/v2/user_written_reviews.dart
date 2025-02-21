import 'package:json_annotation/json_annotation.dart';

part 'user_written_reviews.g.dart';

@JsonSerializable()
class UserWrittenReviews {
  @JsonKey(name: 'written_host_review_id')
  final int? writtenHostReviewId; // null 가능

  @JsonKey(name: 'written_participation_ids')
  final List<int> writtenParticipationIds;

  UserWrittenReviews({
    this.writtenHostReviewId,
    required this.writtenParticipationIds,
  });

  factory UserWrittenReviews.fromJson(Map<String, dynamic> json) =>
      _$UserWrittenReviewsFromJson(json);

  Map<String, dynamic> toJson() => _$UserWrittenReviewsToJson(this);

  UserWrittenReviews copyWith({
    int? writtenHostReviewId,
    List<int>? writtenParticipationIds,
  }) {
    return UserWrittenReviews(
      writtenHostReviewId: writtenHostReviewId ?? this.writtenHostReviewId,
      writtenParticipationIds: writtenParticipationIds ?? List.from(this.writtenParticipationIds),
    );
  }
}
