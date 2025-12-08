import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../../court/model/court_model.dart';

part 'game_recent_host_model.g.dart';

@JsonSerializable()
class GameRecentHostModel extends IModelWithId {
  final GameStatusType game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final int fee;
  final int min_invitation;
  final int max_invitation;
  final String info;
  final CourtSearchModel court;
  GameRecentHostModel({
    required super.id,
    required this.title,
    required this.min_invitation,
    required this.max_invitation,
    required this.fee,
    required this.info,
    required this.court,
    required this.game_status,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
  });

  factory GameRecentHostModel.fromJson(Map<String, dynamic> json) =>
      _$GameRecentHostModelFromJson(json);
}
