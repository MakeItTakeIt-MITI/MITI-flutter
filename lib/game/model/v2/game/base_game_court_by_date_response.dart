import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import 'base_game_response.dart';

part 'base_game_court_by_date_response.g.dart';

@JsonSerializable()
class BaseGameCourtByDateResponse extends Base {
  @JsonKey(name: "startdate")
  final String startDate;
  final BaseGameResponse game;

  BaseGameCourtByDateResponse({
    required this.startDate,
    required this.game,
  });

  factory BaseGameCourtByDateResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameCourtByDateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameCourtByDateResponseToJson(this);

  BaseGameCourtByDateResponse copyWith({
    String? startDate,
    BaseGameResponse? game,
  }) {
    return BaseGameCourtByDateResponse(
      game: game ?? this.game,
      startDate: startDate ?? this.startDate,
    );
  }
}
