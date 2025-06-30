import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';
import '../../game/model/game_model.dart';

part 'court_model.g.dart';

@JsonSerializable()
class CourtModel extends IModelWithId {
  final String address;
  final String? address_detail;
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
class CourtDetailModel extends CourtGameModel {
  final List<GameHostModel> soonest_games;

  CourtDetailModel( {
    required super.id,
    required super.address,
    required super.address_detail,
    required super.name,
    required super.info,
    required super.latitude,
    required super.longitude,
    required this.soonest_games,
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


@JsonSerializable()
class CourtGameModel extends CourtModel {
  final String name;
  final String? info;

  CourtGameModel( {
    required super.id,
    required super.address,
    required super.address_detail,
    required this.name,
    required this.info,
    required super.latitude,
    required super.longitude,
  });

  factory CourtGameModel.fromJson(Map<String, dynamic> json) =>
      _$CourtGameModelFromJson(json);
}

@JsonSerializable()
class CourtSearchModel extends CourtModel {
  final String name;

  CourtSearchModel({
    required super.id,
    required super.address,
    required super.address_detail,
    required super.latitude,
    required super.longitude,
    required this.name,
  });

  factory CourtSearchModel.fromJson(Map<String, dynamic> json) =>
      _$CourtSearchModelFromJson(json);
}
