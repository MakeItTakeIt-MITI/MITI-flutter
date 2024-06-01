import 'package:json_annotation/json_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../provider/widget/sign_up_form_provider.dart';

part 'auth_param.g.dart';

@JsonSerializable()
class RequestNewPasswordParam {
  final String email;

  RequestNewPasswordParam({required this.email});

  Map<String, dynamic> toJson() => _$RequestNewPasswordParamToJson(this);
}

@JsonSerializable()
class ResetPasswordParam {
  final String new_password;
  final String new_password_check;

  ResetPasswordParam(
      {required this.new_password, required this.new_password_check});

  factory ResetPasswordParam.fromModel({required SignFormModel model}) {
    return ResetPasswordParam(
        new_password: model.password, new_password_check: model.checkPassword);
  }

  Map<String, dynamic> toJson() => _$ResetPasswordParamToJson(this);
}

@JsonSerializable()
class OauthLoginParam {
  OauthLoginParam();

  Map<String, dynamic> toJson() => _$OauthLoginParamToJson(this);
}

@JsonSerializable()
class KakaoLoginParam extends OauthLoginParam {
  final String access_token;

  KakaoLoginParam({
    required this.access_token,
  });

  @override
  Map<String, dynamic> toJson() => _$KakaoLoginParamToJson(this);
}

@JsonSerializable()
class AppleLoginParam extends OauthLoginParam {
  final String? identity_token;
  final String authorization_code;
  final String? email;

  AppleLoginParam({
    required this.identity_token,
    required this.authorization_code,
    required this.email,
  });

  factory AppleLoginParam.fromModel(
      {required AuthorizationCredentialAppleID credential}) {
    return AppleLoginParam(
      identity_token: credential.identityToken,
      authorization_code: credential.authorizationCode,
      email: credential.email,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$AppleLoginParamToJson(this);
}
