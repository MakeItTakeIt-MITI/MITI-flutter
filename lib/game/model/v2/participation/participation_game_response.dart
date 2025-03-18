import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/kakaopay/model/pay_model.dart';
import '../../../../user/model/v2/base_user_response.dart';
import '../game/base_game_response.dart';
import 'base_participation_response.dart';

part 'participation_game_response.g.dart';

@JsonSerializable()
class ParticipationGameResponse extends PayBaseModel {
  final int id;
  @JsonKey(name: 'participation_status')
  final ParticipationStatusType participationStatus;
  final BaseUserResponse user;
  final BaseGameResponse game;

  ParticipationGameResponse({
    required this.id,
    required this.game,
    required this.user,
    required this.participationStatus,
  });

  factory ParticipationGameResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationGameResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipationGameResponseToJson(this);

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
