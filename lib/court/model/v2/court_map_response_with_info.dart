import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/model_id.dart';

part 'court_map_response_with_info.g.dart';

@JsonSerializable()
class CourtMapResponseWithInfo extends IModelWithId {
  final String? name;
  final String address;
  @JsonKey(name: 'address_detail')
  final String? addressDetail;
  final String? latitude;
  final String? longitude;
  final String? info;

  CourtMapResponseWithInfo({
    required super.id,
    this.name,
    required this.address,
    this.addressDetail,
    this.latitude,
    this.longitude,
    this.info,
  });

  factory CourtMapResponseWithInfo.fromJson(Map<String, dynamic> json) =>
      _$CourtMapResponseWithInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CourtMapResponseWithInfoToJson(this);

  CourtMapResponseWithInfo copyWith({
    int? id,
    String? name,
    String? address,
    String? addressDetail,
    String? latitude,
    String? longitude,
    String? info,
  }) {
    return CourtMapResponseWithInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      addressDetail: addressDetail ?? this.addressDetail,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      info: info ?? this.info,
    );
  }
}