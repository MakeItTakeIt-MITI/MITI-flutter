import 'package:json_annotation/json_annotation.dart';

part 'base_guest_rating_response.g.dart';

abstract class BaseRatingResponse {
  @JsonKey(name: 'average_rating')
  final double? averageRating; // 평균 평점 (리뷰가 없는 경우 null)
  @JsonKey(name: 'num_of_reviews')
  final int numOfReviews; // 리뷰 개수
  BaseRatingResponse({
    this.averageRating,
    required this.numOfReviews,
  });
}

@JsonSerializable()
class BaseGuestRatingResponse extends BaseRatingResponse {

  BaseGuestRatingResponse({
    super.averageRating,
    required super.numOfReviews,
  });

  factory BaseGuestRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGuestRatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGuestRatingResponseToJson(this);

  BaseGuestRatingResponse copyWith({
    double? averageRating,
    int? numOfReviews,
  }) {
    return BaseGuestRatingResponse(
      averageRating: averageRating ?? this.averageRating,
      numOfReviews: numOfReviews ?? this.numOfReviews,
    );
  }
}
