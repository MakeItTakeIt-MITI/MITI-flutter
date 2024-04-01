import 'package:json_annotation/json_annotation.dart';

part 'find_email_model.g.dart';

@JsonSerializable()
class FindEmailModel {
  final String authentication_token;

  FindEmailModel({required this.authentication_token});

  factory FindEmailModel.fromJson(Map<String, dynamic> json) =>
      _$FindEmailModelFromJson(json);
}
