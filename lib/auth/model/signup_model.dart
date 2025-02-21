import 'package:json_annotation/json_annotation.dart';
import 'package:miti/auth/model/auth_model.dart';

import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import 'code_model.dart';

part 'signup_model.g.dart';

@JsonSerializable()
class SignUpModel extends IModelWithId {
  final String email;
  final String nickname;
  final SignupMethodType signup_method;
  final TokenModel token;

  SignUpModel({
    required super.id,
    required this.email,
    required this.nickname,
    required this.signup_method,
    required this.token,
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) =>
      _$SignUpModelFromJson(json);
}
// @JsonSerializable()
// class SignUserModel extends CodeUserModel{
//
//   SignUserModel({required super.email, required super.nickname});
//
//   @override
//   factory SignUserModel.fromJson(Map<String, dynamic> json) =>
//       _$SignUserModelFromJson(json);
// }

@JsonSerializable()
class SignUpCheckModel {
  final DuplicateCheckModel email;
  // final DuplicateCheckModel? nickname;

  SignUpCheckModel({
    required this.email,
    // required this.nickname,
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
