//
// "id": 7,
// "request_type": "game_participation",
// "is_required": true,
// "policy": {
// "id": 7,
// "name": "경기 참가 정보 수집 및 활용정책",
// "type": "policy",
// "content": "test policy abce",
// "created_at": "2024-09-26T22:41:09.036391+09:00",
// "modified_at": "2024-09-26T22:41:09.036466+09:00"
// }

import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'agreement_policy_model.g.dart';

@JsonSerializable()
class AgreementPolicyModel extends IModelWithId {
  final AgreementRequestType request_type;
  final bool is_required;
  final PolicyModel policy;

  AgreementPolicyModel({
    required super.id,
    required this.request_type,
    required this.is_required,
    required this.policy,
  });

  factory AgreementPolicyModel.fromJson(Map<String, dynamic> json) =>
      _$AgreementPolicyModelFromJson(json);
}

@JsonSerializable()
class PolicyModel extends IModelWithId {
  final String name;
  final PolicyType type;
  final String content;
  final String created_at;
  final String modified_at;

  PolicyModel({
    required super.id,
    required this.name,
    required this.type,
    required this.content,
    required this.created_at,
    required this.modified_at,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) =>
      _$PolicyModelFromJson(json);
}
