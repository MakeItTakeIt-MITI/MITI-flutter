import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/entity_enum.dart';

part 'base_player_profile_response.g.dart';

@JsonSerializable()
class BasePlayerProfileResponse {
  final GenderType? gender; // 성별
  final int? height; // 신장
  final int? weight; // 체중
  final PlayerPositionType? position; // 포지션
  final PlayerRoleType? role; // 역할

  BasePlayerProfileResponse({
    this.gender,
    this.height,
    this.weight,
    this.position,
    this.role,
  });

  /// JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory BasePlayerProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$BasePlayerProfileResponseFromJson(json);

  /// 객체를 JSON 데이터로 변환
  Map<String, dynamic> toJson() => _$BasePlayerProfileResponseToJson(this);

  /// copyWith 메소드 추가
  BasePlayerProfileResponse copyWith({
    GenderType? gender,
    int? height,
    int? weight,
    PlayerPositionType? position,
    PlayerRoleType? role,
  }) {
    return BasePlayerProfileResponse(
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      position: position ?? this.position,
      role: role ?? this.role,
    );
  }
}
