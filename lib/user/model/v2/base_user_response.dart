import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/model_id.dart';

part 'base_user_response.g.dart';

@JsonSerializable()
class BaseUserResponse extends NullIModelWithId {
  final String nickname; // 닉네임
  @JsonKey(name: 'profile_image_url')
  final String profileImageUrl; // 프로필 이미지 URL

  BaseUserResponse({
    super.id,
    required this.nickname,
    required this.profileImageUrl,
  });

  /// JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory BaseUserResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseUserResponseFromJson(json);

  /// 객체를 JSON 데이터로 변환
  Map<String, dynamic> toJson() => _$BaseUserResponseToJson(this);

  /// copyWith 메소드 추가
  BaseUserResponse copyWith({
    int? id,
    String? nickname,
    String? profileImageUrl,
  }) {
    return BaseUserResponse(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
