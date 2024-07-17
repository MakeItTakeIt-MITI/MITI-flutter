import 'package:json_annotation/json_annotation.dart';

import '../provider/widget/sign_up_form_provider.dart';

part 'signup_param.g.dart';

@JsonSerializable()
class SignUpBaseParam {
  final String nickname;
  final String name;
  final String birthday;

  SignUpBaseParam({
    required this.nickname,
    required this.name,
    required this.birthday,
  });

  Map<String, dynamic> toJson() => _$SignUpBaseParamToJson(this);
}

@JsonSerializable()
class SignUpEmailParam extends SignUpBaseParam {
  final String email;
  final String phone;
  final String password;
  final String password_check;
  final String signup_token;

  SignUpEmailParam({
    required this.email,
    required this.phone,
    required super.nickname,
    required super.name,
    required super.birthday,
    required this.password,
    required this.password_check,
    required this.signup_token,
  });

  @override
  Map<String, dynamic> toJson() => _$SignUpEmailParamToJson(this);
}

@JsonSerializable()
class SignUpAppleParam extends SignUpBaseParam {
  final String phone;
  final String signup_token;
  final String userinfo_token;

  SignUpAppleParam({
    required this.phone,
    required super.nickname,
    required super.name,
    required super.birthday,
    required this.signup_token,
    required this.userinfo_token,
  });

  @override
  Map<String, dynamic> toJson() => _$SignUpAppleParamToJson(this);
}

@JsonSerializable()
class SignUpKakaoParam extends SignUpBaseParam {
  final String userinfo_token;

  SignUpKakaoParam({
    required super.nickname,
    required super.name,
    required super.birthday,
    required this.userinfo_token,
  });

  @override
  Map<String, dynamic> toJson() => _$SignUpKakaoParamToJson(this);
}

@JsonSerializable()
class SignUpParam {
  final String email;
  final String nickname;
  final String name;
  final String phone;
  final String password;
  final String password_check;
  final String birthday;

  SignUpParam({
    required this.email,
    required this.nickname,
    required this.name,
    required this.phone,
    required this.password,
    required this.password_check,
    required this.birthday,
  });

  Map<String, dynamic> toJson() => _$SignUpParamToJson(this);

  factory SignUpParam.fromForm({required SignFormModel model}) {
    return SignUpParam(
      email: model.email,
      nickname: model.nickname,
      name: model.name,
      phone: model.phoneNumber.replaceAll('-', ''),
      password: model.password,
      password_check: model.checkPassword,
      birthday: model.birthDate.replaceAll(' / ', '-'),
    );
  }
}

@JsonSerializable()
class BaseParam {
  Map<String, dynamic> toJson() => _$BaseParamToJson(this);
}

@JsonSerializable()
class EmailCheckParam extends BaseParam {
  final String email;

  EmailCheckParam({
    required this.email,
  });

  @override
  Map<String, dynamic> toJson() => _$EmailCheckParamToJson(this);
}

@JsonSerializable()
class NicknameCheckParam extends BaseParam {
  final String nickname;

  NicknameCheckParam({
    required this.nickname,
  });

  @override
  Map<String, dynamic> toJson() => _$NicknameCheckParamToJson(this);
}

@JsonSerializable()
class CodeParam {
  final String code;

  CodeParam({
    required this.code,
  });

  Map<String, dynamic> toJson() => _$CodeParamToJson(this);
}
