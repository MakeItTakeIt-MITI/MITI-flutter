import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../common/model/default_model.dart';
import '../../court/model/court_model.dart';

part 'game_recent_host_model.g.dart';

@JsonSerializable()
class GameRecentHostModel extends IModelWithId {
  final int min_invitation;
  final int max_invitation;
  final int fee;
  final String info;
  final CourtDetailModel court;

  GameRecentHostModel({
    required super.id,
    required this.min_invitation,
    required this.max_invitation,
    required this.fee,
    required this.info,
    required this.court,
  });

  factory GameRecentHostModel.fromJson(Map<String, dynamic> json) =>
      _$GameRecentHostModelFromJson(json);
}
