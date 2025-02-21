import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/model_id.dart';
import '../../../user/model/v2/user_guest_rating_response.dart';
import '../../../user/model/v2/user_host_rating_response.dart';
import 'base_guest_rating_response.dart';
import 'base_guest_review_response.dart';
import 'base_host_rating_response.dart';

part 'host_review_list_response.g.dart';

@JsonSerializable()
class HostReviewListResponse {
  final UserHostRatingResponse reviewee;
  final List<BaseGuestReviewResponse> reviews;

  HostReviewListResponse({
    required this.reviewee,
    required this.reviews,
  });

  factory HostReviewListResponse.fromJson(Map<String, dynamic> json) =>
      _$HostReviewListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HostReviewListResponseToJson(this);

  HostReviewListResponse copyWith({
    UserHostRatingResponse? reviewee,
    List<BaseGuestReviewResponse>? reviews,
  }) {
    return HostReviewListResponse(
      reviewee: reviewee ?? this.reviewee,
      reviews: reviews ?? this.reviews,
    );
  }
}
