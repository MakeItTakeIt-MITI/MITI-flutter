import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../../../court/model/v2/base_court_response.dart';
import '../../../../court/model/v2/court_map_response.dart';
import 'base_game_response.dart';

part 'base_game_with_court_map_response.g.dart';

@JsonSerializable()
class BaseGameWithCourtMapResponse extends BaseGameResponse {
  final CourtMapResponse court;

  BaseGameWithCourtMapResponse({
    required super.id,
    required super.gameStatus,
    required super.title,
    required super.startDate,
    required super.startTime,
    required super.endDate,
    required super.endTime,
    required this.court,
  });

  factory BaseGameWithCourtMapResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameWithCourtMapResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BaseGameWithCourtMapResponseToJson(this);

  @override
  BaseGameWithCourtMapResponse copyWith({
    int? id,
    GameStatusType? gameStatus,
    String? title,
    String? startDate,
    String? startTime,
    String? endDate,
    String? endTime,
    CourtMapResponse? court,
  }) {
    return BaseGameWithCourtMapResponse(
      id: id ?? this.id,
      gameStatus: gameStatus ?? this.gameStatus,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      court: court ?? this.court,
    );
  }
}
