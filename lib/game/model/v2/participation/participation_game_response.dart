import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import '../../../../user/model/v2/base_user_response.dart';
import '../game/base_game_response.dart';
import 'base_participation_response.dart';

part 'participation_game_response.g.dart';

@JsonSerializable()
class ParticipationGameResponse extends BaseParticipationResponse {
  final BaseGameResponse game;

  ParticipationGameResponse({
    required super.id,
    required this.game,
    required super.user,
    required super.participationStatus,
  });

  factory ParticipationGameResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationGameResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipationGameResponseToJson(this);

  @override
  ParticipationGameResponse copyWith({
    int? id,
    ParticipationStatusType? participationStatus,
    BaseUserResponse? user,
    BaseGameResponse? game,
  }) {
    return ParticipationGameResponse(
      id: id ?? this.id,
      participationStatus: participationStatus ?? this.participationStatus,
      user: user ?? this.user,
      game: game ?? this.game,
    );
  }
}
