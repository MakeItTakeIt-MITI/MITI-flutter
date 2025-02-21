import 'package:json_annotation/json_annotation.dart';
import 'package:miti/game/model/v2/participation/participation_guest_rating_response.dart';
import '../../../user/model/v2/user_host_rating_response.dart';
import 'user_written_reviews.dart';

part 'game_reviewee_list_response.g.dart';

@JsonSerializable()
class GameRevieweeListResponse {
  @JsonKey(name: 'user_participation_id')
  final int userParticipationId;
  final UserHostRatingResponse host;
  final List<ParticipationGuestRatingResponse> participations;
  @JsonKey(name: 'user_written_reviews')
  final UserWrittenReviews userWrittenReviews;

  GameRevieweeListResponse({
    required this.userParticipationId,
    required this.host,
    required this.participations,
    required this.userWrittenReviews,
  });

  factory GameRevieweeListResponse.fromJson(Map<String, dynamic> json) =>
      _$GameRevieweeListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GameRevieweeListResponseToJson(this);

  GameRevieweeListResponse copyWith({
    int? userParticipationId,
    UserHostRatingResponse? host,
    List<ParticipationGuestRatingResponse>? participations,
    UserWrittenReviews? userWrittenReviews,
  }) {
    return GameRevieweeListResponse(
      userParticipationId: userParticipationId ?? this.userParticipationId,
      host: host ?? this.host,
      participations: participations ?? List.from(this.participations),
      userWrittenReviews: userWrittenReviews ?? this.userWrittenReviews,
    );
  }
}
