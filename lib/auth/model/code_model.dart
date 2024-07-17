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
class SendCodeModel {
  final String phone;
  final PhoneAuthType purpose;
  final String authentication_token;

  SendCodeModel({
    required this.phone,
    required this.purpose,
    required this.authentication_token,
  });

  factory SendCodeModel.fromJson(Map<String, dynamic> json) =>
      _$SendCodeModelFromJson(json);
}