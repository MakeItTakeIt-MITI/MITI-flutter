import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';
import 'package:miti/game/model/v2/participation/base_participation_response.dart';

import '../../../../common/model/entity_enum.dart';
import '../../../../court/model/v2/court_map_response.dart';
import '../../../../user/model/v2/user_host_rating_response.dart';
import 'game_response.dart';

part 'full_game_court_response.g.dart';

@JsonSerializable()
class FullGameCourtResponse extends GameResponse {
  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'modified_at')
  final String? modifiedAt;

  final UserHostRatingResponse host;

  final CourtMapResponse court;

  final List<BaseParticipationResponse> participations;

  FullGameCourtResponse({
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
    required this.createdAt,
    this.modifiedAt,
    required this.host,
    required this.court,
    required this.participations,
  });

  factory FullGameCourtResponse.fromJson(Map<String, dynamic> json) =>
      _$FullGameCourtResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FullGameCourtResponseToJson(this);

  // CopyWith method
  @override
  FullGameCourtResponse copyWith({
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
    String? createdAt,
    String? modifiedAt,
    UserHostRatingResponse? host,
    CourtMapResponse? court,
    List<BaseParticipationResponse>? participations,
  }) {
    return FullGameCourtResponse(
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
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      host: host ?? this.host,
      court: court ?? this.court,
      participations: participations ?? this.participations,
    );
  }
}
