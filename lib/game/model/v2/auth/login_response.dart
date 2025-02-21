import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';
import 'base_token_response.dart'; // Assuming BaseTokenResponse is in the same directory

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse extends IModelWithId {
  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'nickname')
  final String nickname;

  @JsonKey(name: 'signup_method')
  final SignupMethodType signupMethod;

  @JsonKey(name: 'token')
  final BaseTokenResponse token;

  LoginResponse({
    required super.id,
    required this.email,
    required this.nickname,
    required this.signupMethod,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  LoginResponse copyWith({
    int? id,
    String? email,
    String? nickname,
    SignupMethodType? signupMethod,
    BaseTokenResponse? token,
  }) {
    return LoginResponse(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      signupMethod: signupMethod ?? this.signupMethod,
      token: token ?? this.token,
    );
  }
}
