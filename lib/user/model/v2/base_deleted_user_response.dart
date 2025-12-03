import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_deleted_user_response.g.dart';

@JsonSerializable()
class BaseDeletedUserResponse extends IModelWithId {
  @JsonKey(name: 'nickname')
  final String nickname;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'signup_method')
  final SignupMethodType signupMethod;

  @JsonKey(name: 'user_restore_token')
  final String userRestoreToken;

  BaseDeletedUserResponse({
    required super.id,
    required this.nickname,
    required this.name,
    required this.signupMethod,
    required this.userRestoreToken,
  });

  factory BaseDeletedUserResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseDeletedUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseDeletedUserResponseToJson(this);

  BaseDeletedUserResponse copyWith({
    int? id,
    String? nickname,
    String? name,
    SignupMethodType? signupMethod,
    String? userRestoreToken,
  }) {
    return BaseDeletedUserResponse(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      name: name ?? this.name,
      signupMethod: signupMethod ?? this.signupMethod,
      userRestoreToken: userRestoreToken ?? this.userRestoreToken,
    );
  }
}
