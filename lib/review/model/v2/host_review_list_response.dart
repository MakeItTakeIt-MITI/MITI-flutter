import 'package:json_annotation/json_annotation.dart';

import '../../../user/model/v2/user_host_rating_response.dart';
import 'base_host_review_response.dart';

part 'host_review_list_response.g.dart';

abstract class BaseReviewListResponse {}

@JsonSerializable()
class HostReviewListResponse extends BaseReviewListResponse {
  final UserHostRatingResponse reviewee;
  final List<BaseHostReviewResponse> reviews;

  HostReviewListResponse({
    required this.reviewee,
    required this.reviews,
  });

  factory HostReviewListResponse.fromJson(Map<String, dynamic> json) =>
      _$HostReviewListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HostReviewListResponseToJson(this);

  HostReviewListResponse copyWith({
    UserHostRatingResponse? reviewee,
    List<BaseHostReviewResponse>? reviews,
  }) {
    return HostReviewListResponse(
      reviewee: reviewee ?? this.reviewee,
      reviews: reviews ?? this.reviews,
    );
  }
}
