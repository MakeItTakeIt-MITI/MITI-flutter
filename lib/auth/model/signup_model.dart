import 'package:json_annotation/json_annotation.dart';

import 'code_model.dart';

part 'signup_model.g.dart';

@JsonSerializable()
class SignUpModel {
  final SignUserModel user;
  final String authentication_token;

  SignUpModel({
    required this.user,
    required this.authentication_token,
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) =>
      _$SignUpModelFromJson(json);
}
@JsonSerializable()
class SignUserModel extends CodeUserModel{
  SignUserModel({required super.email, required super.nickname});

  @override
  factory SignUserModel.fromJson(Map<String, dynamic> json) =>
      _$SignUserModelFromJson(json);
}



@JsonSerializable()
class SignUpCheckModel {
  final DuplicateCheckModel? email;
  final DuplicateCheckModel? nickname;

  SignUpCheckModel({
    required this.email,
    required this.nickname,
  });

  factory SignUpCheckModel.fromJson(Map<String, dynamic> json) =>
      _$SignUpCheckModelFromJson(json);
}



@JsonSerializable()
class DuplicateCheckModel {
  final String value;
  final bool is_duplicated;

  DuplicateCheckModel({
    required this.value,
    required this.is_duplicated,
  });

  factory DuplicateCheckModel.fromJson(Map<String, dynamic> json) =>
      _$DuplicateCheckModelFromJson(json);
}
