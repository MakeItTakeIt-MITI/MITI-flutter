import 'package:json_annotation/json_annotation.dart';
import 'package:miti/game/model/game_model.dart';

import '../../common/model/entity_enum.dart';
import '../../court/model/court_model.dart';
part 'game_refund_model.g.dart';

@JsonSerializable()
class GameRefundModel extends GameBaseModel {
  final int fee;
  final int num_of_participations;
  final int min_invitation;
  final int max_invitation;

  GameRefundModel({
    required super.id,
    required super.title,
    required super.game_status,
    required super.startdate,
    required super.starttime,
    required super.enddate,
    required super.endtime,
    required super.court,
    required this.fee,
    required this.num_of_participations,
    required this.min_invitation,
    required this.max_invitation,
  });


  factory GameRefundModel.fromJson(Map<String, dynamic> json) =>
      _$GameRefundModelFromJson(json);
}
