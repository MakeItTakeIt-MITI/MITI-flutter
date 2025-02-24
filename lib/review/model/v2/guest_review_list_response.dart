import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/model_id.dart';
import '../../../user/model/v2/user_guest_rating_response.dart';
import 'base_guest_rating_response.dart';
import 'base_guest_review_response.dart';
import 'base_host_rating_response.dart';
import 'host_review_list_response.dart';

part 'guest_review_list_response.g.dart';

@JsonSerializable()
class GuestReviewListResponse extends BaseReviewListResponse {
  final UserGuestRatingResponse reviewee;
  final List<BaseGuestReviewResponse> reviews;

  GuestReviewListResponse({
    required this.reviewee,
    required this.reviews,
  });

  factory GuestReviewListResponse.fromJson(Map<String, dynamic> json) =>
      _$GuestReviewListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GuestReviewListResponseToJson(this);

  GuestReviewListResponse copyWith({
    UserGuestRatingResponse? reviewee,
    List<BaseGuestReviewResponse>? reviews,
  }) {
    return GuestReviewListResponse(
      reviewee: reviewee ?? this.reviewee,
      reviews: reviews ?? this.reviews,
    );
  }
}
