import 'package:json_annotation/json_annotation.dart';
import 'package:miti/user/model/v2/private_user_guest_player_response.dart';

import '../../../common/model/entity_enum.dart';
import '../../../common/model/model_id.dart';

part 'private_participation_guest_player_response.g.dart';

@JsonSerializable()
class PrivateParticipationGuestPlayerResponse extends IModelWithId {
  @JsonKey(name: 'participation_status')
  final ParticipationStatusType participationStatus;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'modified_at')
  final DateTime modifiedAt;

  final PrivateUserGuestPlayerResponse user;

  PrivateParticipationGuestPlayerResponse({
    required super.id,
    required this.participationStatus,
    required this.createdAt,
    required this.modifiedAt,
    required this.user,
  });

  factory PrivateParticipationGuestPlayerResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivateParticipationGuestPlayerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateParticipationGuestPlayerResponseToJson(this);

  PrivateParticipationGuestPlayerResponse copyWith({
    int? id,
    ParticipationStatusType? participationStatus,
    DateTime? createdAt,
    DateTime? modifiedAt,
    PrivateUserGuestPlayerResponse? user,
  }) {
    return PrivateParticipationGuestPlayerResponse(
      id: id ?? this.id,
      participationStatus: participationStatus ?? this.participationStatus,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      user: user ?? this.user,
    );
  }
}