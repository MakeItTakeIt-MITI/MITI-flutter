import 'package:json_annotation/json_annotation.dart';

part 'auth_param.g.dart';

@JsonSerializable()
class RequestNewPasswordParam {
  final String email;

  RequestNewPasswordParam({required this.email});

  Map<String, dynamic> toJson() => _$RequestNewPasswordParamToJson(this);
}

@JsonSerializable()
class ResetPasswordParam {
  final String password;
  final String password_check;

  ResetPasswordParam({required this.password, required this.password_check});

  Map<String, dynamic> toJson() => _$ResetPasswordParamToJson(this);
}

@JsonSerializable()
class OauthLoginParam {
  final String access_token;

  OauthLoginParam({required this.access_token,});

  Map<String, dynamic> toJson() => _$OauthLoginParamToJson(this);
}