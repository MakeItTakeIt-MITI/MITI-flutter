import 'package:json_annotation/json_annotation.dart';
import 'package:miti/user/model/v2/private_user_player_profile.dart';

import '../../../review/model/v2/base_guest_rating_response.dart';
import 'base_player_profile_response.dart';

part 'private_user_guest_player_response.g.dart';

@JsonSerializable()
class PrivateUserGuestPlayerResponse extends PrivateUserPlayerProfile {
  @JsonKey(name: 'guest_rating')
  final BaseGuestRatingResponse guestRating;

  PrivateUserGuestPlayerResponse({
    super.id,
    required super.name,
    required super.nickname,
    required super.profileImageUrl,
    required super.playerProfile,
    required this.guestRating,
  });

  factory PrivateUserGuestPlayerResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivateUserGuestPlayerResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrivateUserGuestPlayerResponseToJson(this);

  @override
  PrivateUserGuestPlayerResponse copyWith({
    int? id,
    String? name,
    String? nickname,
    String? profileImageUrl,
    BasePlayerProfileResponse? playerProfile,
    BaseGuestRatingResponse? guestRating,
  }) {
    return PrivateUserGuestPlayerResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      playerProfile: playerProfile ?? this.playerProfile,
      guestRating: guestRating ?? this.guestRating,
    );
  }
}