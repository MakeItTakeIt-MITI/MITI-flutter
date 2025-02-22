import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';

part 'find_info_model.g.dart';

enum FindInfoType { email, password }

@JsonSerializable()
class FindInfoModel {
  final String authentication_token;

  FindInfoModel({required this.authentication_token});

  factory FindInfoModel.fromJson(Map<String, dynamic> json) =>
      _$FindInfoModelFromJson(json);
}

@JsonSerializable()
class VerifyBaseModel {
  final String? phone;
  final PhoneAuthenticationPurposeType? purpose;
  @JsonKey(includeFromJson: false)
  final SignupMethodType? authType;

  VerifyBaseModel({
    required this.phone,
    required this.purpose,
    this.authType,
  });

  factory VerifyBaseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyBaseModelFromJson(json);
}

@JsonSerializable()
class SignUpVerifyModel extends VerifyBaseModel {
  @JsonKey(name: 'is_authenticated')
  final bool isAuthenticated;
  @JsonKey(name: 'signup_token')
  final String signupToken;

  SignUpVerifyModel({
    required super.phone,
    required super.purpose,
    required this.isAuthenticated,
    required this.signupToken,
    super.authType,
  });

  @override
  factory SignUpVerifyModel.fromJson(Map<String, dynamic> json) =>
      _$SignUpVerifyModelFromJson(json);
}

@JsonSerializable()
class EmailVerifyModel extends VerifyBaseModel {
  final int? id;
  final String? email;
  @JsonKey(name: 'password_update_token')
  final String? passwordUpdateToken;

  EmailVerifyModel({
    this.id,
    this.email,
    super.phone,
    super.purpose,
    this.passwordUpdateToken,
    super.authType,
  });

  @override
  factory EmailVerifyModel.fromJson(Map<String, dynamic> json) =>
      _$EmailVerifyModelFromJson(json);
}

@JsonSerializable()
class PasswordVerifyModel extends VerifyBaseModel {
  final int? id;
  @JsonKey(name: 'password_update_token')
  final String? passwordUpdateToken;

  PasswordVerifyModel({
    this.id,
    super.phone,
    super.purpose,
    this.passwordUpdateToken,
    super.authType,
  });

  @override
  factory PasswordVerifyModel.fromJson(Map<String, dynamic> json) =>
      _$PasswordVerifyModelFromJson(json);
}
