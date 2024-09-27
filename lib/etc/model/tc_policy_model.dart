import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../common/model/entity_enum.dart';

part 'tc_policy_model.g.dart';

@JsonSerializable()
class TcPolicyModel extends IModelWithId {
  final PolicyType type;
  final String name;

  TcPolicyModel({
    required super.id,
    required this.type,
    required this.name,
  });

  factory TcPolicyModel.fromJson(Map<String, dynamic> json) =>
      _$TcPolicyModelFromJson(json);
}

@JsonSerializable()
class TcPolicyDetailModel extends TcPolicyModel {
  final String content;
  final String created_at;
  final String modified_at;

  TcPolicyDetailModel({
    required super.id,
    required super.type,
    required super.name,
    required this.content,
    required this.created_at,
    required this.modified_at,
  });

  factory TcPolicyDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TcPolicyDetailModelFromJson(json);
}
