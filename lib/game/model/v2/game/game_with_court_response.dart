import 'package:json_annotation/json_annotation.dart';

import '../../../../common/model/entity_enum.dart';
import '../../../../common/model/model_id.dart';
import '../../../../court/model/v2/base_court_response.dart';
import 'game_response.dart';

part 'game_with_court_response.g.dart';

@JsonSerializable()
class GameWithCourtResponse extends GameResponse {
  final BaseCourtResponse court;

  GameWithCourtResponse({
    required super.id,
    required super.gameStatus,
    required super.title,
    required super.startDate,
    required super.startTime,
    required super.endDate,
    required super.endTime,
    required super.minInvitation,
    required super.maxInvitation,
    required super.numOfParticipations,
    required super.fee,
    required super.info,
    required this.court,
  });

  factory GameWithCourtResponse.fromJson(Map<String, dynamic> json) =>
      _$GameWithCourtResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GameWithCourtResponseToJson(this);

  @override
  GameWithCourtResponse copyWith({
    int? id,
    GameStatusType? gameStatus,
    String? title,
    String? startDate,
    String? startTime,
    String? endDate,
    String? endTime,
    int? minInvitation,
    int? maxInvitation,
    int? numOfParticipations,
    int? fee,
    String? info,
    BaseCourtResponse? court,
  }) {
    return GameWithCourtResponse(
      id: id ?? this.id,
      gameStatus: gameStatus ?? this.gameStatus,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      minInvitation: minInvitation ?? this.minInvitation,
      maxInvitation: maxInvitation ?? this.maxInvitation,
      numOfParticipations: numOfParticipations ?? this.numOfParticipations,
      fee: fee ?? this.fee,
      info: info ?? this.info,
      court: court ?? this.court,
    );
  }
}
