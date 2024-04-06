import 'package:json_annotation/json_annotation.dart';

part 'find_info_model.g.dart';
enum FindInfoType { email, password }

@JsonSerializable()
class FindInfoModel {
  final String authentication_token;

  FindInfoModel({required this.authentication_token});

  factory FindInfoModel.fromJson(Map<String, dynamic> json) =>
      _$FindInfoModelFromJson(json);
}
