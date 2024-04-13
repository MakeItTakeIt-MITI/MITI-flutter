import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

class AuthModel {
  final int? id;
  final String? email;
  final String? nickname;
  final bool? is_authenticated;
  final TokenModel? token;

  AuthModel({
    required this.id,
    required this.email,
    required this.nickname,
    required this.is_authenticated,
    required this.token,
  });

  AuthModel copyWith({
    int? id,
    String? email,
    String? nickname,
    bool? is_authenticated,
    TokenModel? token,
  }) {
    return AuthModel(
      token: token ?? this.token,
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      is_authenticated: is_authenticated ?? this.is_authenticated,
    );
  }
}

@JsonSerializable()
class LoginModel {
  final int id;
  final String email;
  final String nickname;
  final bool is_authenticated;
  final TokenModel token;

  LoginModel({
    required this.id,
    required this.email,
    required this.nickname,
    required this.is_authenticated,
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
