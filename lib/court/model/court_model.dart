import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'court_model.g.dart';

@JsonSerializable()
class CourtModel extends IModelWithId {
  final String address;
  final String address_detail;
  final String latitude;
  final String longitude;

  CourtModel({
    required super.id,
    required this.address,
    required this.address_detail,
    required this.latitude,
    required this.longitude,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) =>
      _$CourtModelFromJson(json);
}

@JsonSerializable()
class CourtDetailModel extends CourtModel {
  final String name;
  final String? info;

  CourtDetailModel({
    required super.id,
    required super.address,
    required super.address_detail,
    required this.name,
    required this.info,
    required super.latitude,
    required super.longitude,
  });

  factory CourtDetailModel.fromJson(Map<String, dynamic> json) =>
      _$CourtDetailModelFromJson(json);
}

@JsonSerializable()
class CourtAddressModel extends IModelWithId {
  final String name;
  final String address;
  final String address_detail;

  CourtAddressModel({
    required super.id,
    required this.name,
    required this.address,
    required this.address_detail,
  });

  factory CourtAddressModel.fromJson(Map<String, dynamic> json) =>
      _$CourtAddressModelFromJson(json);
}
