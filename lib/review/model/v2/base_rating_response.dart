import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/model_id.dart';
import 'base_guest_rating_response.dart';
import 'base_host_rating_response.dart';

part 'base_rating_response.g.dart';

@JsonSerializable()
class BaseRatingResponse {
  @JsonKey(name: 'host_rating')
  final BaseGuestRatingResponse hostRating; // 모르겠으면 나중에 정의 필요
  @JsonKey(name: 'guest_rating')
  final BaseHostRatingResponse guestRating; // 모르겠으면 나중에 정의 필요

  BaseRatingResponse({
    required this.hostRating,
    required this.guestRating,
  });

  factory BaseRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseRatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseRatingResponseToJson(this);

  BaseRatingResponse copyWith({
    BaseGuestRatingResponse? hostRating,
    BaseHostRatingResponse? guestRating,
  }) {
    return BaseRatingResponse(
      hostRating: hostRating ?? this.hostRating,
      guestRating: guestRating ?? this.guestRating,
    );
  }
}
