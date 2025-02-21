import 'package:json_annotation/json_annotation.dart';
import '../../../common/model/model_id.dart';
import 'base_player_profile_response.dart';
import 'base_user_response.dart';

part 'user_player_profile_response.g.dart';

@JsonSerializable()
class UserPlayerProfileResponse extends BaseUserResponse {
  @JsonKey(name: 'player_profile')
  final BasePlayerProfileResponse playerProfile; // 플레이어 프로필

  UserPlayerProfileResponse({
    super.id,
    required super.nickname,
    required super.profileImageUrl,
    required this.playerProfile,
  });

  factory UserPlayerProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserPlayerProfileResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserPlayerProfileResponseToJson(this);

  @override
  UserPlayerProfileResponse copyWith({
    int? id,
    String? nickname,
    String? profileImageUrl,
    BasePlayerProfileResponse? playerProfile,
  }) {
    return UserPlayerProfileResponse(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      playerProfile: playerProfile ?? this.playerProfile,
    );
  }
}
