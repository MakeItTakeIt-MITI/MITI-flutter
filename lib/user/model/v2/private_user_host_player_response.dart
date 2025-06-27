import 'package:json_annotation/json_annotation.dart';
import 'package:miti/user/model/v2/private_user_player_profile.dart';

import '../../../review/model/v2/base_host_rating_response.dart';
import 'base_player_profile_response.dart';

part 'private_user_host_player_response.g.dart';

@JsonSerializable()
class PrivateUserHostPlayerResponse extends PrivateUserPlayerProfile {
  @JsonKey(name: 'host_rating')
  final BaseHostRatingResponse hostRating;

  PrivateUserHostPlayerResponse({
    super.id,
    required super.name,
    required super.nickname,
    required super.profileImageUrl,
    required super.playerProfile,
    required this.hostRating,
  });

  factory PrivateUserHostPlayerResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivateUserHostPlayerResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrivateUserHostPlayerResponseToJson(this);

  @override
  PrivateUserHostPlayerResponse copyWith({
    int? id,
    String? name,
    String? nickname,
    String? profileImageUrl,
    BasePlayerProfileResponse? playerProfile,
    BaseHostRatingResponse? hostRating,
  }) {
    return PrivateUserHostPlayerResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      playerProfile: playerProfile ?? this.playerProfile,
      hostRating: hostRating ?? this.hostRating,
    );
  }
}