import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';
import 'package:miti/game/model/v2/participation/base_participation_response.dart';

import '../../../../court/model/v2/court_map_response.dart';
import '../../../../user/model/v2/user_host_rating_response.dart';

part 'game_detail_response.g.dart';

@JsonSerializable()
class GameDetailResponse extends IModelWithId {
  final GameStatusType game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final int min_invitation;
  final int max_invitation;
  final int num_of_participations;
  final int fee;
  final String info;
  final DateTime created_at;
  final DateTime? modified_at;
  final UserHostRatingResponse host;
  final CourtMapResponse court;
  final List<BaseParticipationResponse> participations;
  final bool is_host;
  final int? user_participation_id;

  GameDetailResponse({
    required super.id,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.min_invitation,
    required this.max_invitation,
    required this.num_of_participations,
    required this.fee,
    required this.info,
    required this.created_at,
    this.modified_at,
    required this.host,
    required this.court,
    required this.participations,
    required this.is_host,
    this.user_participation_id,
  });

  factory GameDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$GameDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GameDetailResponseToJson(this);

  // CopyWith method
  @override
  GameDetailResponse copyWith({
    int? id,
    GameStatusType? game_status,
    String? titile,
    String? startdate,
    String? starttime,
    String? enddate,
    String? endtime,
    int? min_invitation,
    int? max_invitation,
    int? num_of_participations,
    int? fee,
    String? info,
    DateTime? created_at,
    DateTime? modified_at,
    UserHostRatingResponse? host,
    CourtMapResponse? court,
    List<BaseParticipationResponse>? participations,
    bool? is_host,
    int? user_participation_id,
  }) {
    return GameDetailResponse(
      id: id ?? this.id,
      game_status: game_status ?? this.game_status,
      title: titile ?? this.title,
      startdate: startdate ?? this.startdate,
      starttime: starttime ?? this.starttime,
      enddate: enddate ?? this.enddate,
      endtime: endtime ?? this.endtime,
      min_invitation: min_invitation ?? this.min_invitation,
      max_invitation: max_invitation ?? this.max_invitation,
      num_of_participations:
          num_of_participations ?? this.num_of_participations,
      fee: fee ?? this.fee,
      info: info ?? this.info,
      created_at: created_at ?? this.created_at,
      modified_at: modified_at ?? this.modified_at,
      host: host ?? this.host,
      court: court ?? this.court,
      participations: participations ?? this.participations,
      is_host: is_host ?? this.is_host,
      user_participation_id:
          user_participation_id ?? this.user_participation_id,
    );
  }
}
