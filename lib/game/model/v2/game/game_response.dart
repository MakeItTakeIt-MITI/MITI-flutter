import 'package:json_annotation/json_annotation.dart';

import '../../../../common/model/entity_enum.dart';
import '../../../../common/model/model_id.dart';
import 'base_game_response.dart';

part 'game_response.g.dart';

@JsonSerializable()
class GameResponse extends BaseGameResponse {
  @JsonKey(name: 'min_invitation')
  final int minInvitation;
  @JsonKey(name: 'max_invitation')
  final int maxInvitation;
  @JsonKey(name: 'num_of_participations')
  final int numOfParticipations;
  final int fee;
  final String info;

  GameResponse({
    required super.id,
    required super.gameStatus,
    required super.title,
    required super.startDate,
    required super.startTime,
    required super.endDate,
    required super.endTime,
    required this.minInvitation,
    required this.maxInvitation,
    required this.numOfParticipations,
    required this.fee,
    required this.info,
  });

  factory GameResponse.fromJson(Map<String, dynamic> json) =>
      _$GameResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GameResponseToJson(this);

  @override
  GameResponse copyWith({
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
  }) {
    return GameResponse(
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
    );
  }
}
