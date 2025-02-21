import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/model_id.dart';
import 'base_court_response.dart';

part 'court_map_response.g.dart';

@JsonSerializable()
class CourtMapResponse extends BaseCourtResponse {
  final String latitude;
  final String longitude;

  CourtMapResponse({
    required super.id,
    super.name,
    required super.address,
    super.addressDetail,
    required this.latitude,
    required this.longitude,
  });

  factory CourtMapResponse.fromJson(Map<String, dynamic> json) =>
      _$CourtMapResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CourtMapResponseToJson(this);

  @override
  CourtMapResponse copyWith({
    int? id,
    String? name,
    String? address,
    String? addressDetail,
    String? latitude,
    String? longitude,
  }) {
    return CourtMapResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      addressDetail: addressDetail ?? this.addressDetail,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
