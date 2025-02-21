import 'package:json_annotation/json_annotation.dart';

part 'base_host_rating_response.g.dart';

@JsonSerializable()
class BaseHostRatingResponse {
  @JsonKey(name: 'average_rating')
  final double? averageRating; // 평균 평점 (리뷰가 없는 경우 null)
  @JsonKey(name: 'num_of_reviews')
  final int numOfReviews; // 리뷰 개수

  BaseHostRatingResponse({
    this.averageRating,
    required this.numOfReviews,
  });

  factory BaseHostRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseHostRatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseHostRatingResponseToJson(this);

  BaseHostRatingResponse copyWith({
    double? averageRating,
    int? numOfReviews,
  }) {
    return BaseHostRatingResponse(
      averageRating: averageRating ?? this.averageRating,
      numOfReviews: numOfReviews ?? this.numOfReviews,
    );
  }
}