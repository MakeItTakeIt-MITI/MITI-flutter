import 'package:json_annotation/json_annotation.dart';

import '../../../../common/model/entity_enum.dart';
import '../../../../common/model/model_id.dart';

part 'base_game_response.g.dart';

@JsonSerializable()
class BaseGameResponse extends IModelWithId {
  @JsonKey(name: 'game_status')
  final GameStatusType gameStatus;
  final String title;
  @JsonKey(name: 'startdate')
  final String startDate;
  @JsonKey(name: 'starttime')
  final String startTime;
  @JsonKey(name: 'enddate')
  final String endDate;
  @JsonKey(name: 'endtime')
  final String endTime;

  BaseGameResponse({
    required super.id,
    required this.gameStatus,
    required this.title,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
  });

  factory BaseGameResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameResponseToJson(this);

  BaseGameResponse copyWith({
    int? id,
    GameStatusType? gameStatus,
    String? title,
    String? startDate,
    String? startTime,
    String? endDate,
    String? endTime,
  }) {
    return BaseGameResponse(
      id: id ?? this.id,
      gameStatus: gameStatus ?? this.gameStatus,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
    );
  }
}
