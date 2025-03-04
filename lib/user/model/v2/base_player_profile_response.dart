import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/entity_enum.dart';

part 'base_player_profile_response.g.dart';

class PlayerProfileForm extends BasePlayerProfileResponse {
  final bool enableGender;

  PlayerProfileForm({
    required this.enableGender,
    super.gender,
    super.height,
    super.weight,
    super.position,
    super.role,
  });

  /// copyWith 메소드 추가
  @override
  PlayerProfileForm copyWith({
    GenderType? gender,
    int? height,
    int? weight,
    PlayerPositionType? position,
    PlayerRoleType? role,
    bool? enableGender,
  }) {
    return PlayerProfileForm(
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      position: position ?? this.position,
      role: role ?? this.role,
      enableGender: enableGender ?? this.enableGender,
    );
  }

  factory PlayerProfileForm.fromModel(
      {required BasePlayerProfileResponse model}) {
    return PlayerProfileForm(
      gender: model.gender,
      height: model.height,
      weight: model.weight,
      position: model.position,
      role: model.role,
      enableGender: model.gender == null,
    );
  }
}

@JsonSerializable(includeIfNull: false)
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

  bool validWeight() {
    if (weight != null) {
      return 30 <= weight! && weight! <= 150;
    }
    return true;
  }

  bool validHeight() {
    if (height != null) {
      return 50 <= height! && height! <= 230;
    }
    return true;
  }

  bool validForm() {
    return validHeight() && validWeight();
  }
}
