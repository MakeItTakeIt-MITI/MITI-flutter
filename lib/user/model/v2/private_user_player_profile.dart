import 'package:json_annotation/json_annotation.dart';
import 'package:miti/user/model/v2/private_base_user_response.dart';

import 'base_player_profile_response.dart';

part 'private_user_player_profile.g.dart';

@JsonSerializable()
class PrivateUserPlayerProfile extends PrivateBaseUserResponse {
  @JsonKey(name: 'player_profile')
  final BasePlayerProfileResponse playerProfile;

  PrivateUserPlayerProfile({
    super.id,
    required super.name,
    required super.nickname,
    required super.profileImageUrl,
    required this.playerProfile,
  });

  factory PrivateUserPlayerProfile.fromJson(Map<String, dynamic> json) =>
      _$PrivateUserPlayerProfileFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrivateUserPlayerProfileToJson(this);

  @override
  PrivateUserPlayerProfile copyWith({
    int? id,
    String? name,
    String? nickname,
    String? profileImageUrl,
    BasePlayerProfileResponse? playerProfile,
  }) {
    return PrivateUserPlayerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      playerProfile: playerProfile ?? this.playerProfile,
    );
  }
}