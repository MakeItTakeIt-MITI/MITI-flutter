import 'package:json_annotation/json_annotation.dart';

import '../../../game/model/v2/game/game_response.dart';
import 'court_response.dart';

part 'court_operations_response.g.dart';

@JsonSerializable()
class CourtOperationsResponse extends CourtResponse {
  @JsonKey(name: 'soonest_games')
  final List<GameResponse> soonestGames;

  CourtOperationsResponse({
    required super.id,
    super.name,
    required super.address,
    super.addressDetail,
    required super.latitude,
    required super.longitude,
    super.info,
    required this.soonestGames,
  });

  factory CourtOperationsResponse.fromJson(Map<String, dynamic> json) =>
      _$CourtOperationsResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CourtOperationsResponseToJson(this);

  @override
  CourtOperationsResponse copyWith({
    int? id,
    String? name,
    String? address,
    String? addressDetail,
    String? latitude,
    String? longitude,
    String? info,
    List<GameResponse>? soonestGames,
  }) {
    return CourtOperationsResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      addressDetail: addressDetail ?? this.addressDetail,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      info: info ?? this.info,
      soonestGames: soonestGames ?? this.soonestGames,
    );
  }
}
