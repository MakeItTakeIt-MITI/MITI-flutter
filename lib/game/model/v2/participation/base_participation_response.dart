import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../../user/model/v2/base_user_response.dart';

part 'base_participation_response.g.dart';

@JsonSerializable()
class BaseParticipationResponse extends IModelWithId {
  @JsonKey(name: 'participation_status')
  final ParticipationStatusType participationStatus;
  final BaseUserResponse user;

  BaseParticipationResponse({
    required this.participationStatus,
    required this.user,
    required super.id,
  });

  
  factory BaseParticipationResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseParticipationResponseFromJson(json);

  // CopyWith method
  BaseParticipationResponse copyWith({
    int? id,
    ParticipationStatusType? participationStatus,
    BaseUserResponse? user,
  }) {
    return BaseParticipationResponse(
      id: id ?? this.id,
      participationStatus: participationStatus ?? this.participationStatus,
      user: user ?? this.user,
    );
  }
}
