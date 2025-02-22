import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../game/model/v2/auth/base_token_response.dart';

part 'auth_model.g.dart';

class AuthModel {
  final int? id;
  final String? email;
  final String? nickname;
  final SignupMethodType? signUpType;
  final BaseTokenResponse? token;

  AuthModel({
    required this.id,
    required this.email,
    required this.nickname,
    required this.signUpType,
    required this.token,
  });

  AuthModel copyWith({
    int? id,
    String? email,
    String? nickname,
    SignupMethodType? signUpType,
    BaseTokenResponse? token,
  }) {
    return AuthModel(
      token: token ?? this.token,
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      signUpType: signUpType ?? this.signUpType,
    );
  }
}

@JsonSerializable()
class LoginModel {
  final int id;
  final String email;
  final String nickname;
  final SignupMethodType signup_method;

  final TokenModel token;

  LoginModel({
    required this.id,
    required this.email,
    required this.nickname,
    required this.signup_method,
    required this.token,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);
}

@JsonSerializable()
class TokenModel {
  final String? access;
  final String? refresh;
  final String? type;

  TokenModel({
    required this.access,
    required this.refresh,
    required this.type,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      _$TokenModelFromJson(json);
}

@JsonSerializable()
class RequestNewPasswordModel {
  final int id;
  final String email;

  RequestNewPasswordModel({
    required this.id,
    required this.email,
  });

  factory RequestNewPasswordModel.fromJson(Map<String, dynamic> json) =>
      _$RequestNewPasswordModelFromJson(json);
}
