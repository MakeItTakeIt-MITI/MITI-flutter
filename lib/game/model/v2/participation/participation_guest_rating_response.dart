import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../../user/model/v2/user_guest_rating_response.dart';

part 'participation_guest_rating_response.g.dart';

@JsonSerializable()
class ParticipationGuestRatingResponse extends IModelWithId {

  @JsonKey(name: 'participation_status')
  final ParticipationStatusType participationStatus;

  final UserGuestRatingResponse user;

  ParticipationGuestRatingResponse({
    required super.id,
    required this.participationStatus,
    required this.user,
  });

  factory ParticipationGuestRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$ParticipationGuestRatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipationGuestRatingResponseToJson(this);

  ParticipationGuestRatingResponse copyWith({
    int? id,
    ParticipationStatusType? participationStatus,
    UserGuestRatingResponse? user,
  }) {
    return ParticipationGuestRatingResponse(
      id: id ?? this.id,
      participationStatus: participationStatus ?? this.participationStatus,
      user: user ?? this.user,
    );
  }
}
