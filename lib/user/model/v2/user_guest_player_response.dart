import 'package:json_annotation/json_annotation.dart';
import '../../../common/model/model_id.dart';
import '../../../review/model/v2/base_guest_rating_response.dart';
import 'base_player_profile_response.dart';
import 'base_user_response.dart';

part 'user_guest_player_response.g.dart';

@JsonSerializable()
class UserGuestPlayerResponse extends BaseUserResponse {
  @JsonKey(name: 'guest_rating')
  final BaseGuestRatingResponse guestRating; // 게스트 평점
  @JsonKey(name: 'player_profile')
  final BasePlayerProfileResponse playerProfile; // 플레이어 프로필

  UserGuestPlayerResponse({
    super.id,
    required super.nickname,
    required super.profileImageUrl,
    required this.guestRating,
    required this.playerProfile,
  });

  factory UserGuestPlayerResponse.fromJson(Map<String, dynamic> json) =>
      _$UserGuestPlayerResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserGuestPlayerResponseToJson(this);

  @override
  UserGuestPlayerResponse copyWith({
    int? id,
    String? nickname,
    String? profileImageUrl,
    BaseGuestRatingResponse? guestRating,
    BasePlayerProfileResponse? playerProfile,
  }) {
    return UserGuestPlayerResponse(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      guestRating: guestRating ?? this.guestRating,
      playerProfile: playerProfile ?? this.playerProfile,
    );
  }
}
