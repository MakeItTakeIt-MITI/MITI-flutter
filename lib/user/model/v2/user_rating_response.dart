import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../review/model/v2/base_guest_rating_response.dart';
import '../../../review/model/v2/base_host_rating_response.dart';
import 'base_user_response.dart';

part 'user_rating_response.g.dart';

@JsonSerializable()
class UserRatingResponse extends BaseUserResponse {
  @JsonKey(name: 'host_rating')
  final BaseHostRatingResponse hostRating; // 호스트 평점
  @JsonKey(name: 'guest_rating')
  final BaseGuestRatingResponse guestRating; // 게스트 평점

  UserRatingResponse({
    super.id,
    required super.nickname,
    required super.profileImageUrl,
    required this.hostRating,
    required this.guestRating,
  });

  factory UserRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$UserRatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserRatingResponseToJson(this);

  UserRatingResponse copyWith({
    int? id,
    String? nickname,
    String? profileImageUrl,
    BaseHostRatingResponse? hostRating,
    BaseGuestRatingResponse? guestRating,
  }) {
    return UserRatingResponse(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      hostRating: hostRating ?? this.hostRating,
      guestRating: guestRating ?? this.guestRating,
    );
  }
}
