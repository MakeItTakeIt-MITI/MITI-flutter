import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';

part 'code_model.g.dart';

// @JsonSerializable()
// class RequestCodeModel {
//   final CodeUserModel user;
//   final String authentication_token;
//
//   RequestCodeModel({
//     required this.user,
//     required this.authentication_token,
//   });
//
//   factory RequestCodeModel.fromJson(Map<String, dynamic> json) =>
//       _$RequestCodeModelFromJson(json);
// }

// @JsonSerializable()
// class CodeUserModel {
//   final String email;
//   final String nickname;
//
//   CodeUserModel({
//     required this.email,
//     required this.nickname,
//   });
//
//   factory CodeUserModel.fromJson(Map<String, dynamic> json) =>
//       _$CodeUserModelFromJson(json);
// }

@JsonSerializable()
class ResponseCodeModel {
  final String email;
  final bool is_authenticated;
  final bool is_oauth;

  ResponseCodeModel({
    required this.email,
    required this.is_authenticated,
    required this.is_oauth,
  });

  factory ResponseCodeModel.fromJson(Map<String, dynamic> json) =>
      _$ResponseCodeModelFromJson(json);
}

@JsonSerializable()
class UpdateTokenBaseModel {
  final String phone;
  final PhoneAuthType purpose;

  UpdateTokenBaseModel({
    required this.phone,
    required this.purpose,
  });

  factory UpdateTokenBaseModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateTokenBaseModelFromJson(json);
}

@JsonSerializable()
class SendCodeModel extends UpdateTokenBaseModel {
  final String authentication_token;

  SendCodeModel({
    required super.phone,
    required super.purpose,
    required this.authentication_token,
  });

  factory SendCodeModel.fromJson(Map<String, dynamic> json) =>
      _$SendCodeModelFromJson(json);
}

@JsonSerializable()
class UpdateTokenModel extends UpdateTokenBaseModel {
  final int id;
  final String password_update_token;

  UpdateTokenModel({
    required this.id,
    required super.phone,
    required super.purpose,
    required this.password_update_token,
  });

  factory UpdateTokenModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateTokenModelFromJson(json);
}
