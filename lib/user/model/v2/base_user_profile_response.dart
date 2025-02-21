import 'package:json_annotation/json_annotation.dart';

part 'base_user_profile_response.g.dart';

@JsonSerializable()
class BaseUserProfileResponse {
  final String nickname; // 닉네임
  @JsonKey(name: 'profile_image_url')
  final String profileImageUrl; // 프로필 이미지 URL
  @JsonKey(name: 'profile_image_update_url')
  final String profileImageUpdateUrl; // 프로필 이미지 업로드 URL

  BaseUserProfileResponse({
    required this.nickname,
    required this.profileImageUrl,
    required this.profileImageUpdateUrl,
  });

  factory BaseUserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseUserProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseUserProfileResponseToJson(this);

  BaseUserProfileResponse copyWith({
    String? nickname,
    String? profileImageUrl,
    String? profileImageUpdateUrl,
  }) {
    return BaseUserProfileResponse(
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImageUpdateUrl: profileImageUpdateUrl ?? this.profileImageUpdateUrl,
    );
  }
}