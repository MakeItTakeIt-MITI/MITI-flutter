import 'package:json_annotation/json_annotation.dart';
import 'package:miti/user/model/v2/user_rating_response.dart';

import '../../../common/model/entity_enum.dart';
import '../../../review/model/v2/base_guest_rating_response.dart';
import '../../../review/model/v2/base_host_rating_response.dart';
import 'base_player_profile_response.dart';

part 'user_info_response.g.dart';

@JsonSerializable()
class UserInfoResponse extends UserRatingResponse {
  final String name; // 이름
  final String birthday; // 생일
  final String phone; // 연락처
  @JsonKey(name: 'signup_method')
  final SignupMethodType signupMethod; // 회원가입 방식 (SignupMethod로 대체 가능)
  @JsonKey(name: 'player_profile')
  final BasePlayerProfileResponse playerProfile; // 플레이어 프로필

  UserInfoResponse({
    super.id,
    required super.nickname,
    required this.name,
    required this.birthday,
    required this.phone,
    required this.signupMethod,
    required super.profileImageUrl,
    required super.guestRating,
    required super.hostRating,
    required this.playerProfile,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$UserInfoResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserInfoResponseToJson(this);

  @override
  UserInfoResponse copyWith({
    int? id,
    String? nickname,
    String? name,
    String? birthday,
    String? phone,
    SignupMethodType? signupMethod,
    String? profileImageUrl,
    BaseGuestRatingResponse? guestRating,
    BaseHostRatingResponse? hostRating,
    BasePlayerProfileResponse? playerProfile,
  }) {
    return UserInfoResponse(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      signupMethod: signupMethod ?? this.signupMethod,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      guestRating: guestRating ?? this.guestRating,
      playerProfile: playerProfile ?? this.playerProfile,
      hostRating: hostRating ?? this.hostRating,
    );
  }
}
