import 'package:json_annotation/json_annotation.dart';

import 'court_map_response.dart';

part 'court_response.g.dart';

@JsonSerializable()
class CourtResponse extends CourtMapResponse {
  final String? info;

  CourtResponse({
    required super.id,
    super.name,
    required super.address,
    super.addressDetail,
    required super.latitude,
    required super.longitude,
    this.info,
  });

  factory CourtResponse.fromJson(Map<String, dynamic> json) =>
      _$CourtResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CourtResponseToJson(this);

  @override
  CourtResponse copyWith({
    int? id,
    String? name,
    String? address,
    String? addressDetail,
    String? latitude,
    String? longitude,
    String? info,
  }) {
    return CourtResponse(
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
