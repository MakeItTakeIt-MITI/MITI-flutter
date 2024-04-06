import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'court_model.g.dart';

@JsonSerializable()
class CourtModel extends IModelWithId {
  final String address;
  final String address_detail;

  CourtModel({
    required super.id,
    required this.address,
    required this.address_detail,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) =>
      _$CourtModelFromJson(json);
}

@JsonSerializable()
class CourtDetailModel extends IModelWithId {
  final String address;
  final String address_detail;
  final String name;
  final String? info;

  CourtDetailModel({
    required super.id,
    required this.address,
    required this.address_detail,
    required this.name,
    required this.info,
  });

  factory CourtDetailModel.fromJson(Map<String, dynamic> json) =>
      _$CourtDetailModelFromJson(json);
}
