import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../../common/model/default_model.dart';
import '../../court/model/court_model.dart';
import 'game_model.dart';

part 'game_recent_host_model.g.dart';

/*
            "id": 28201,
            "game_status": "canceled",
            "title": "[5:5 3파전]미티 금요일 픽업게임",
            "startdate": "2024-09-13",
            "starttime": "20:00:00",
            "enddate": "2024-09-13",
            "endtime": "23:00:00",
            "max_invitation": 10,
            "min_invitation": 1,
            "fee": 5000,
            "info": "경기 운영\n\n어쩌구 저쩌구\n가나다라 마바가\n\n\n시설 정보\n\n\n주의사항",
            "court": {
                "id": 2,
                "address": "서울 강남구 언주로168길 32",
                "address_detail": "월송빌딩 지하1층",
                "latitude": "37.5258947809397",
                "longitude": "127.036184100776"
            }

 */
@JsonSerializable()
class GameRecentHostModel extends IModelWithId {
  final GameStatus game_status;
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
