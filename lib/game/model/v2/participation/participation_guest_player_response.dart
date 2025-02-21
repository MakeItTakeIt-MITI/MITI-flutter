import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../../user/model/v2/user_guest_player_response.dart';

part 'participation_guest_player_response.g.dart';

@JsonSerializable()
class ParticipationGuestPlayerResponse extends IModelWithId{

  @JsonKey(name: 'participation_status')
  final ParticipationStatusType participationStatus;

  final UserGuestPlayerResponse user;

  ParticipationGuestPlayerResponse({
    required super.id,
    required this.participationStatus,
    required this.user,
  });

  factory ParticipationGuestPlayerResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationGuestPlayerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipationGuestPlayerResponseToJson(this);

  ParticipationGuestPlayerResponse copyWith({
    int? id,
    ParticipationStatusType? participationStatus,
    UserGuestPlayerResponse? user,
  }) {
    return ParticipationGuestPlayerResponse(
      id: id ?? this.id,
      participationStatus: participationStatus ?? this.participationStatus,
      user: user ?? this.user,
    );
  }
}
