import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../review/model/v2/base_guest_rating_response.dart';
import 'base_user_response.dart';

part 'user_guest_rating_response.g.dart';

@JsonSerializable()
class UserGuestRatingResponse extends BaseUserResponse {
  @JsonKey(name: 'guest_rating')
  final BaseGuestRatingResponse guestRating; // 게스트 평점

  UserGuestRatingResponse({
    super.id,
    required super.nickname,
    required super.profileImageUrl,
    required this.guestRating,
  });

  factory UserGuestRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$UserGuestRatingResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserGuestRatingResponseToJson(this);

  @override
  UserGuestRatingResponse copyWith({
    int? id,
    String? nickname,
    String? profileImageUrl,
    BaseGuestRatingResponse? guestRating,
  }) {
    return UserGuestRatingResponse(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      guestRating: guestRating ?? this.guestRating,
    );
  }
}
