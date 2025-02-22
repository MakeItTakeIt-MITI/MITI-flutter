import 'package:json_annotation/json_annotation.dart';

import 'base_guest_rating_response.dart';

part 'base_host_rating_response.g.dart';

@JsonSerializable()
class BaseHostRatingResponse extends BaseRatingResponse {
  BaseHostRatingResponse({
    super.averageRating,
    required super.numOfReviews,
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
